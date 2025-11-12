-- Complete user_book table enhancement script
-- Run this script in phpMyAdmin to add image_url and drive_link columns

-- Step 1: Add columns if they don't exist
-- Check and add image_url column
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA = DATABASE() 
                   AND TABLE_NAME = 'user_book' 
                   AND COLUMN_NAME = 'image_url');

SET @sql = IF(@col_exists = 0, 
              'ALTER TABLE `user_book` ADD COLUMN `image_url` VARCHAR(500) DEFAULT NULL COMMENT "Book cover image URL"', 
              'SELECT "image_url column already exists" as status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Check and add drive_link column  
SET @col_exists = (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
                   WHERE TABLE_SCHEMA = DATABASE() 
                   AND TABLE_NAME = 'user_book' 
                   AND COLUMN_NAME = 'drive_link');

SET @sql = IF(@col_exists = 0, 
              'ALTER TABLE `user_book` ADD COLUMN `drive_link` VARCHAR(500) DEFAULT NULL COMMENT "Google Drive shareable link"', 
              'SELECT "drive_link column already exists" as status');
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Show current table structure
SELECT 'Current user_book table structure:' as info;
DESCRIBE `user_book`;

-- Step 3: Check what data is available in books table
SELECT 'Books with image_url and drive_link:' as info;
SELECT title, image_url, drive_link 
FROM books 
WHERE image_url IS NOT NULL OR drive_link IS NOT NULL
LIMIT 10;

-- Step 4: Check current user_book data
SELECT 'Current user_book records:' as info;
SELECT book_name, image_url, drive_link, price, days, created_at
FROM user_book 
ORDER BY created_at DESC 
LIMIT 5;

-- Step 5: Update existing user_book records with data from books table
-- Using EXACT title match
UPDATE `user_book` ub
JOIN `books` b ON ub.book_name = b.title
SET 
  ub.image_url = COALESCE(ub.image_url, b.image_url),
  ub.drive_link = COALESCE(ub.drive_link, b.drive_link)
WHERE (b.image_url IS NOT NULL OR b.drive_link IS NOT NULL)
  AND (ub.image_url IS NULL OR ub.drive_link IS NULL);

-- Step 6: Update with LIKE match for partial matches
UPDATE `user_book` ub
JOIN `books` b ON b.title LIKE CONCAT('%', ub.book_name, '%') 
                OR ub.book_name LIKE CONCAT('%', b.title, '%')
SET 
  ub.image_url = COALESCE(ub.image_url, b.image_url),
  ub.drive_link = COALESCE(ub.drive_link, b.drive_link)
WHERE (b.image_url IS NOT NULL OR b.drive_link IS NOT NULL)
  AND (ub.image_url IS NULL OR ub.drive_link IS NULL);

-- Step 7: Show results after update
SELECT 'Updated user_book records:' as info;
SELECT 
  book_name, 
  image_url, 
  drive_link,
  price,
  days,
  created_at
FROM user_book 
WHERE image_url IS NOT NULL OR drive_link IS NOT NULL
ORDER BY created_at DESC;

-- Step 8: Show statistics
SELECT 'Migration Statistics:' as info;
SELECT 
  COUNT(*) as total_user_book_records,
  COUNT(image_url) as records_with_image,
  COUNT(drive_link) as records_with_drive_link,
  COUNT(CASE WHEN image_url IS NOT NULL AND drive_link IS NOT NULL THEN 1 END) as records_with_both
FROM user_book;
FROM user_book 
ORDER BY created_at DESC 
LIMIT 10;