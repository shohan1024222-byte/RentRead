-- Add Google Drive link column to books table
-- Run this in your MySQL/phpMyAdmin

ALTER TABLE books ADD COLUMN drive_link VARCHAR(500) DEFAULT NULL COMMENT 'Google Drive shareable link for the book';

-- Optional: Update existing books with sample drive links (you can do this manually later)
-- UPDATE books SET drive_link = 'https://drive.google.com/file/d/EXAMPLE_FILE_ID/view?usp=sharing' WHERE id = 1;

-- To check if column was added successfully:
-- DESCRIBE books;