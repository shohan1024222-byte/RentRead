const express = require('express');
const pool = require('../db');
const auth = require('../middleware/authMiddleware');
const router = express.Router();

// rent a book for N days (simulate low-cost subscription)
// body: { bookId, days }
router.post('/rent', auth, async (req, res) => {
  const { bookId, days } = req.body;
  const userId = req.user.id;
  const rentDays = parseInt(days, 10) || 1;
  try {
    // check book exists - accept either numeric id or title
    let books;
    if (!isNaN(Number(bookId))) {
      [books] = await pool.query('SELECT id, title, price_per_day FROM books WHERE id = ?', [Number(bookId)]);
    } else {
      // Try exact title match first
      [books] = await pool.query('SELECT id, title, price_per_day FROM books WHERE title = ?', [bookId]);
      
      // If no exact match, try partial match (for cases like "Database Management" -> "Database")
      if (!books || books.length === 0) {
        [books] = await pool.query('SELECT id, title, price_per_day FROM books WHERE title LIKE ? OR ? LIKE CONCAT("%", title, "%")', [
          `%${bookId}%`, bookId
        ]);
      }
    }
    if (!books || books.length === 0) return res.status(404).json({ error: 'Book not found' });

    const book = books[0];
    // create access record using the canonical numeric book id
    const [result] = await pool.query('INSERT INTO access_records (user_id, book_id, expires_at, active) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL ? DAY), 1)', [userId, book.id, rentDays]);

    // Record complete rental in user_rentals table with all book information
    try {
      // Get complete book information
      const [fullBookData] = await pool.query(
        'SELECT * FROM books WHERE id = ?', 
        [book.id]
      );
      
      if (fullBookData && fullBookData.length > 0) {
        const bookData = fullBookData[0];
        
        // Calculate pricing
        const basePrice = bookData.price_per_day ? parseFloat(bookData.price_per_day) : 15;
        const dailyIncrement = 2;
        const totalPrice = basePrice + ((Math.max(1, rentDays) - 1) * dailyIncrement);
        
        // Debug: Log rental data being stored
        console.log('Storing complete rental to user_rentals:', {
          user_id: userId,
          book_title: bookData.title,
          rental_days: rentDays,
          total_price: totalPrice
        });

        // Insert into user_rentals with matching column structure
        await pool.query(`
          INSERT INTO user_rentals (
            user_id, book_id, rental_days, total_price, rental_date, expiry_date, status,
            title, description, author, price_per_day, total_pages, category, 
            is_available, filename, base_price, daily_increment, max_rental_days,
            image_url, pdf_file, file_size, availability_status, total_rented,
            language, drive_link
          ) VALUES (?, ?, ?, ?, NOW(), DATE_ADD(NOW(), INTERVAL ? DAY), 'active', 
                   ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        `, [
          userId, bookData.id, rentDays, totalPrice, rentDays,
          bookData.title, bookData.description, bookData.author, bookData.price_per_day,
          bookData.total_pages, bookData.category, bookData.is_available, bookData.filename,
          bookData.base_price, bookData.daily_increment, bookData.max_rental_days,
          bookData.image_url, bookData.pdf_file, bookData.file_size, 
          bookData.availability_status, bookData.total_rented, bookData.language, bookData.drive_link
        ]);
      }
    } catch (innerErr) {
      // Do not fail the main rental if logging to user_rentals fails - just log
      console.warn('Failed to insert into user_rentals table:', innerErr.message || innerErr);
    }

    res.json({ success: true, accessId: result.insertId, expiresInDays: rentDays });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Could not create rental' });
  }
});

// user active rentals
router.get('/my', auth, async (req, res) => {
  try {
    const [rows] = await pool.query(`
      SELECT 
        a.id, 
        a.book_id, 
        a.expires_at, 
        a.active, 
        b.title,
        b.pdf_file,
        b.drive_link,
        b.image_url,
        b.category
      FROM access_records a 
      JOIN books b ON a.book_id=b.id 
      WHERE a.user_id=? 
      ORDER BY a.expires_at DESC
    `, [req.user.id]);
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Could not fetch rentals' });
  }
});

// Get user rental history from user_rentals table (new comprehensive table)
router.get('/my-rentals', auth, async (req, res) => {
  try {
    const [rentals] = await pool.query(`
      SELECT 
        id,
        book_id,
        rental_days,
        total_price,
        rental_date,
        expiry_date,
        status,
        title,
        description,
        author,
        price_per_day,
        total_pages,
        category,
        language,
        pdf_file,
        image_url,
        drive_link,
        file_size,
        CASE 
          WHEN expiry_date > NOW() THEN TRUE 
          ELSE FALSE 
        END as is_active,
        DATEDIFF(expiry_date, NOW()) as days_remaining
      FROM user_rentals 
      WHERE user_id = ? 
      ORDER BY rental_date DESC
    `, [req.user.id]);
    
    res.json(rentals);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Could not fetch rental history' });
  }
});

// Get user rental history from user_book table
router.get('/user-rentals', auth, async (req, res) => {
  try {
    // Get user email first
    const [users] = await pool.query('SELECT email FROM users WHERE id = ?', [req.user.id]);
    if (!users || users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const userEmail = users[0].email;
    
    // Get rental history from user_book table with book file info
    const [rentals] = await pool.query(`
      SELECT 
        ub.book_name, 
        ub.days, 
        ub.price, 
        ub.created_at as rent_date,
        DATE_ADD(ub.created_at, INTERVAL ub.days DAY) as return_date,
        FALSE as returned,
        COALESCE(ub.image_url, b.image_url) as image_url,
        COALESCE(ub.drive_link, b.drive_link) as drive_link,
        b.pdf_file,
        b.id as book_id
      FROM user_book ub
      LEFT JOIN books b ON ub.book_name = b.title
      WHERE ub.email = ? 
      ORDER BY ub.created_at DESC
    `, [userEmail]);
    
    res.json(rentals);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Could not fetch rental history' });
  }
});

module.exports = router;
