-- Sample Google Drive links for testing
-- Replace with your actual Google Drive file links

-- Update book with ID 1 (change ID as needed)
UPDATE books SET drive_link = 'https://drive.google.com/file/d/1BxbxvOJvF4o8n5_Hq7VwMK3GcJfT9XpY/view?usp=sharing' WHERE id = 1;

-- Update book with ID 2 (change ID as needed)  
UPDATE books SET drive_link = 'https://drive.google.com/file/d/1AbCdEfGhIjKlMnOpQrStUvWxYz123456/view?usp=sharing' WHERE id = 2;

-- Check if updates worked
SELECT id, title, drive_link FROM books WHERE drive_link IS NOT NULL;

-- If you want to test with an actual working public Google Drive file, use this:
-- This is a public PDF document that should work for testing
UPDATE books SET drive_link = 'https://drive.google.com/file/d/1mU8ZG9Qr3TtZYF9VnXj8wLkHpN2oQ4rS/view?usp=sharing' WHERE id = 1;