-- Migration to add image_url column to books table
USE rentread;

-- Add image_url column if it doesn't exist
ALTER TABLE books ADD COLUMN image_url VARCHAR(500) AFTER is_available;

-- Show the updated table structure
DESCRIBE books;
