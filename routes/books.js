const express = require('express');
const pool = require('../db');
const path = require('path');
const fs = require('fs');
const auth = require('../middleware/authMiddleware');
const router = express.Router();

// list available books (with optional search)
router.get('/', async (req, res) => {
  try {
    const q = req.query.q;
    let sql = 'SELECT id, title, description, filename, author, price_per_day, category, total_pages, is_available, image_url, pdf_file, drive_link, created_at FROM books';
    const params = [];
    if (q) {
      sql += ' WHERE title LIKE ? OR category LIKE ? OR author LIKE ?';
      const like = `%${q}%`;
      params.push(like, like, like);
    }
    sql += ' ORDER BY id DESC';
    const [rows] = await pool.query(sql, params);

    // Normalize for frontend: provide image_url if possible
    const normalized = rows.map(r => ({
      ...r,
      image_url: r.image_url || (r.filename && (r.filename.startsWith('http') ? r.filename : `/img/${r.filename}`)) || null,
      price: r.price_per_day ? `৳${r.price_per_day}` : null
    }));

    res.json({ success: true, books: normalized });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Could not fetch books' });
  }
});

// create a new book
router.post('/', async (req, res) => {
  try {
    const { title, description, filename, author, price_per_day, category, total_pages, is_available, image_url, pdf_file, drive_link } = req.body;
    const [result] = await pool.query(`
      INSERT INTO books (title, description, filename, author, price_per_day, category, total_pages, is_available, image_url, pdf_file, drive_link)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [title || '', description || '', filename || '', author || '', price_per_day || 0, category || '', total_pages || 0, is_available ? 1 : 0, image_url || null, pdf_file || null, drive_link || null]);

    const [rows] = await pool.query('SELECT * FROM books WHERE id = ?', [result.insertId]);
    const book = rows[0];
    res.json({ success: true, book });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Could not create book' });
  }
});

// update a book
router.put('/:id', async (req, res) => {
  try {
    const id = req.params.id;
    const { title, description, filename, author, price_per_day, category, total_pages, is_available, image_url, pdf_file, drive_link } = req.body;
    await pool.query(`
      UPDATE books SET title = ?, description = ?, filename = ?, author = ?, price_per_day = ?, category = ?, total_pages = ?, is_available = ?, image_url = ?, pdf_file = ?, drive_link = ?
      WHERE id = ?
    `, [title || '', description || '', filename || '', author || '', price_per_day || 0, category || '', total_pages || 0, is_available ? 1 : 0, image_url || null, pdf_file || null, drive_link || null, id]);

    const [rows] = await pool.query('SELECT * FROM books WHERE id = ?', [id]);
    const book = rows[0];
    res.json({ success: true, book });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Could not update book' });
  }
});

// delete a book
router.delete('/:id', async (req, res) => {
  try {
    const id = req.params.id;
    await pool.query('DELETE FROM books WHERE id = ?', [id]);
    res.json({ success: true, deletedId: id });
  } catch (err) {
    console.error(err);
    res.status(500).json({ success: false, error: 'Could not delete book' });
  }
});

// download a book if user has active access
router.get('/download/:bookId', auth, async (req, res) => {
  const bookId = req.params.bookId;
  const userId = req.user.id;
  try {
    const [access] = await pool.query('SELECT * FROM access_records WHERE user_id=? AND book_id=? AND active=1 AND expires_at > NOW()', [userId, bookId]);
    if (!access || access.length === 0) return res.status(403).json({ error: 'No active rental for this book' });
    const [books] = await pool.query('SELECT filename, title FROM books WHERE id=?', [bookId]);
    if (!books || books.length === 0) return res.status(404).json({ error: 'Book not found' });
    const book = books[0];
    const filePath = path.join(process.env.BOOKS_DIR || 'storage/books', book.filename);
    if (!fs.existsSync(filePath)) return res.status(404).json({ error: 'File not found on server' });
    res.download(filePath, book.filename);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Download failed' });
  }
});

module.exports = router;
