-- Debug script to check books and user_book data
-- Run this in phpMyAdmin to diagnose the data transfer issue

-- 1. Check books table structure and data
SELECT 'BOOKS TABLE STRUCTURE:' as info;
DESCRIBE books;

SELECT 'BOOKS WITH IMAGE_URL OR DRIVE_LINK:' as info;
SELECT id, title, image_url, drive_link, created_at
FROM books 
WHERE image_url IS NOT NULL OR drive_link IS NOT NULL
ORDER BY id
LIMIT 10;

SELECT 'ALL BOOKS (first 10):' as info;
SELECT id, title, 
       CASE WHEN image_url IS NULL THEN 'NULL' ELSE 'HAS VALUE' END as image_status,
       CASE WHEN drive_link IS NULL THEN 'NULL' ELSE 'HAS VALUE' END as drive_status
FROM books 
ORDER BY id
LIMIT 10;

-- 2. Check user_book table structure and data
SELECT 'USER_BOOK TABLE STRUCTURE:' as info;
DESCRIBE user_book;

SELECT 'USER_BOOK RECORDS:' as info;
SELECT id, book_name, 
       CASE WHEN image_url IS NULL THEN 'NULL' ELSE 'HAS VALUE' END as image_status,
       CASE WHEN drive_link IS NULL THEN 'NULL' ELSE 'HAS VALUE' END as drive_status,
       price, days, created_at
FROM user_book 
ORDER BY created_at DESC
LIMIT 10;

-- 3. Check name matching between tables
SELECT 'NAME MATCHING CHECK:' as info;
SELECT 
  ub.book_name as user_book_name,
  b.title as books_title,
  b.image_url,
  b.drive_link,
  CASE 
    WHEN ub.book_name = b.title THEN 'EXACT MATCH'
    WHEN b.title LIKE CONCAT('%', ub.book_name, '%') THEN 'PARTIAL MATCH (books contains user_book)'
    WHEN ub.book_name LIKE CONCAT('%', b.title, '%') THEN 'PARTIAL MATCH (user_book contains books)'
    ELSE 'NO MATCH'
  END as match_type
FROM user_book ub
LEFT JOIN books b ON ub.book_name = b.title OR 
                     b.title LIKE CONCAT('%', ub.book_name, '%') OR
                     ub.book_name LIKE CONCAT('%', b.title, '%')
ORDER BY ub.created_at DESC
LIMIT 10;

-- 4. Count statistics
SELECT 'STATISTICS:' as info;
SELECT 
  (SELECT COUNT(*) FROM books) as total_books,
  (SELECT COUNT(*) FROM books WHERE image_url IS NOT NULL) as books_with_image,
  (SELECT COUNT(*) FROM books WHERE drive_link IS NOT NULL) as books_with_drive_link,
  (SELECT COUNT(*) FROM user_book) as total_user_book_records,
  (SELECT COUNT(*) FROM user_book WHERE image_url IS NOT NULL) as user_book_with_image,
  (SELECT COUNT(*) FROM user_book WHERE drive_link IS NOT NULL) as user_book_with_drive_link;