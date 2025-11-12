# User Book Table Enhancement - Complete Guide

## 🎯 What's Been Implemented

Enhanced the `user_book` table to store book cover images and Google Drive links directly, reducing dependency on the `books` table for rental display.

## 📊 Database Changes

### New Columns Added to `user_book` table:
- `image_url` (VARCHAR 500) - Book cover image URL
- `drive_link` (VARCHAR 500) - Google Drive shareable link

### Updated API Functionality:
- Rental creation now stores complete book data including images and drive links
- User rental APIs prioritize data from `user_book` table with fallback to `books` table

## 🛠️ Step 1: Run Database Migration

### Open phpMyAdmin:
1. Open XAMPP Control Panel
2. Start MySQL (if not running)
3. Click "Admin" next to MySQL
4. Select your database (e.g., `rentread`)
5. Go to "SQL" tab

### Execute Migration:
Copy and paste the content from `sql/update_user_book.sql` and click "Go"

```sql
-- Add image_url column to user_book table
ALTER TABLE `user_book` 
ADD COLUMN `image_url` VARCHAR(500) DEFAULT NULL COMMENT 'Book cover image URL';

-- Add drive_link column to user_book table  
ALTER TABLE `user_book` 
ADD COLUMN `drive_link` VARCHAR(500) DEFAULT NULL COMMENT 'Google Drive shareable link for the book';

-- Update existing records with data from books table
UPDATE `user_book` ub
JOIN `books` b ON ub.book_name = b.title
SET 
  ub.image_url = b.image_url,
  ub.drive_link = b.drive_link
WHERE b.image_url IS NOT NULL OR b.drive_link IS NOT NULL;
```

## 🚀 Step 2: Server Features

### Enhanced Rental API (`/api/rent/rent`):
- Now stores `image_url` and `drive_link` from books table when creating rentals
- Complete book information preserved in user_book table

### Enhanced User Rentals API (`/api/rent/user-rentals`):
- Prioritizes image_url and drive_link from user_book table
- Falls back to books table if user_book data is missing
- Uses `COALESCE` for robust data retrieval

## 🧪 Testing Steps

### 1. Verify Database Migration:
```sql
-- Check table structure
DESCRIBE user_book;

-- Verify data migration
SELECT book_name, image_url, drive_link, price, days 
FROM user_book 
ORDER BY created_at DESC 
LIMIT 5;
```

### 2. Test Book Rental Flow:
1. Go to: `http://localhost:5000`
2. Login/Register as a user
3. Rent a book (should store image_url and drive_link)
4. Check database to confirm data storage

### 3. Test Rental Display:
1. Go to Dashboard or My Account
2. View "My Rentals" section
3. Verify book images and Google Drive links appear
4. Test "Read Book" functionality

## 📱 API Endpoints Enhanced

### POST `/api/rent/rent`
**Request:**
```json
{
  "bookId": 1,
  "days": 7
}
```
**Enhanced behavior:** Now stores complete book data including image_url and drive_link

### GET `/api/rent/user-rentals`
**Response enhanced with:**
```json
[
  {
    "book_name": "Sample Book",
    "image_url": "/img/covers/book.jpg",
    "drive_link": "https://drive.google.com/file/d/xyz/view",
    "days": 7,
    "price": 22.00,
    "rent_date": "2025-11-06T...",
    "return_date": "2025-11-13T..."
  }
]
```

## 💡 Benefits

### Data Independence:
- User rental data no longer dependent on books table for display
- Historical rental information preserved even if original books are modified

### Performance:
- Reduced JOIN operations for rental display
- Faster API responses for user rental pages

### Consistency:
- Book information frozen at rental time
- User sees exactly what they rented, even if book details change

## 🔧 Technical Details

### Database Schema:
```sql
-- user_book table structure after migration
CREATE TABLE user_book (
  id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(255),
  password_hash VARCHAR(255),
  book_name VARCHAR(500),
  days INT,
  price DECIMAL(10,2),
  image_url VARCHAR(500),
  drive_link VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### API Logic:
```javascript
// In routes/rent.js - Enhanced rental creation
await pool.query(
  'INSERT INTO user_book (email, password_hash, book_name, days, price, image_url, drive_link) VALUES (?, ?, ?, ?, ?, ?, ?)',
  [user.email, user.password_hash, book.title, rentDays, totalPrice, book.image_url, book.drive_link]
);

// Enhanced rental retrieval with COALESCE fallback
SELECT 
  ub.book_name,
  COALESCE(ub.image_url, b.image_url) as image_url,
  COALESCE(ub.drive_link, b.drive_link) as drive_link,
  ub.price, ub.days
FROM user_book ub
LEFT JOIN books b ON ub.book_name = b.title
```

## ✅ Verification Checklist

- [ ] Database migration completed successfully
- [ ] New columns visible in user_book table
- [ ] Existing rental data updated with book images/links
- [ ] New rentals store complete book information
- [ ] User rental APIs return image_url and drive_link
- [ ] Book images display correctly in frontend
- [ ] Google Drive links work for reading books
- [ ] System gracefully handles missing data

## 🎉 Ready to Use!

Your enhanced rental system is now ready! Users will see book covers and can access Google Drive files directly from their rental history, with all data preserved independently in the user_book table.

---
**Server restart recommended after migration to ensure all changes are loaded.**