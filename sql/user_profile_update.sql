-- Add phone and address columns to users table
ALTER TABLE users 
ADD COLUMN phone VARCHAR(20) NULL,
ADD COLUMN address TEXT NULL;