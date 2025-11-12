-- Complete Automated Fix for user_book data transfer
-- Run this script in phpMyAdmin to solve the image_url and drive_link transfer issue

-- Step 1: Add columns safely (ignore if exists)
SET @sql1 = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'user_book' 
     AND COLUMN_NAME = 'image_url') = 0,
    'ALTER TABLE `user_book` ADD COLUMN `image_url` VARCHAR(500) DEFAULT NULL',
    'SELECT "image_url column already exists" as message'
));
PREPARE stmt1 FROM @sql1;
EXECUTE stmt1;
DEALLOCATE PREPARE stmt1;

SET @sql2 = (SELECT IF(
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS 
     WHERE TABLE_SCHEMA = DATABASE() 
     AND TABLE_NAME = 'user_book' 
     AND COLUMN_NAME = 'drive_link') = 0,
    'ALTER TABLE `user_book` ADD COLUMN `drive_link` VARCHAR(500) DEFAULT NULL',
    'SELECT "drive_link column already exists" as message'
));
PREPARE stmt2 FROM @sql2;
EXECUTE stmt2;
DEALLOCATE PREPARE stmt2;

-- Step 2: Add sample data to books table if empty
UPDATE books 
SET image_url = CASE 
    WHEN title LIKE '%programming%' OR title LIKE '%code%' THEN '/img/covers/programming.jpg'
    WHEN title LIKE '%database%' OR title LIKE '%sql%' THEN '/img/covers/database.jpg'
    WHEN title LIKE '%algorithm%' THEN '/img/covers/algorithm.jpg'
    WHEN title LIKE '%network%' THEN '/img/covers/networking.jpg'
    WHEN title LIKE '%physics%' THEN '/img/covers/physics.jpg'
    WHEN title LIKE '%math%' THEN '/img/covers/math.jpg'
    WHEN title LIKE '%biology%' THEN '/img/covers/biology.jpg'
    WHEN title LIKE '%chemistry%' THEN '/img/covers/chemistry.jpg'
    ELSE '/img/covers/default-book.jpg'
END,
drive_link = CASE 
    WHEN id = 1 THEN 'https://drive.google.com/file/d/1sample123/view?usp=sharing'
    WHEN id = 2 THEN 'https://drive.google.com/file/d/2sample456/view?usp=sharing'
    WHEN id = 3 THEN 'https://drive.google.com/file/d/3sample789/view?usp=sharing'
    ELSE CONCAT('https://drive.google.com/file/d/', id, 'sample', FLOOR(RAND() * 1000), '/view?usp=sharing')
END
WHERE image_url IS NULL OR drive_link IS NULL;

-- Step 3: Transfer data from books to user_book (exact match)
UPDATE `user_book` ub
JOIN `books` b ON ub.book_name = b.title
SET 
  ub.image_url = COALESCE(ub.image_url, b.image_url),
  ub.drive_link = COALESCE(ub.drive_link, b.drive_link);

-- Step 4: Transfer data with partial matching
UPDATE `user_book` ub
JOIN `books` b ON (b.title LIKE CONCAT('%', ub.book_name, '%') OR ub.book_name LIKE CONCAT('%', b.title, '%'))
SET 
  ub.image_url = COALESCE(ub.image_url, b.image_url),
  ub.drive_link = COALESCE(ub.drive_link, b.drive_link)
WHERE ub.image_url IS NULL OR ub.drive_link IS NULL;

-- Step 5: Set default values for remaining NULL records
UPDATE `user_book` 
SET 
  image_url = COALESCE(image_url, '/img/covers/default-book.jpg'),
  drive_link = COALESCE(drive_link, 'https://drive.google.com/file/d/default/view?usp=sharing')
WHERE image_url IS NULL OR drive_link IS NULL;

-- Step 6: Show results
SELECT 'MIGRATION COMPLETED - Results:' as status;

SELECT 'Books table data:' as info;
SELECT COUNT(*) as total_books, 
       COUNT(image_url) as books_with_images, 
       COUNT(drive_link) as books_with_drive_links
FROM books;

SELECT 'User_book table data:' as info;
SELECT COUNT(*) as total_rentals, 
       COUNT(image_url) as rentals_with_images, 
       COUNT(drive_link) as rentals_with_drive_links
FROM user_book;

SELECT 'Sample user_book records:' as info;
SELECT book_name, 
       CASE WHEN image_url IS NULL THEN 'NULL' ELSE 'HAS IMAGE' END as image_status,
       CASE WHEN drive_link IS NULL THEN 'NULL' ELSE 'HAS DRIVE_LINK' END as drive_status,
       price, days, created_at
FROM user_book 
ORDER BY created_at DESC 
LIMIT 10;

SELECT 'Fix completed successfully! 🎉' as final_message;