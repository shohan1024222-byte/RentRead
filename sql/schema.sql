-- SQL schema for RentRead
CREATE DATABASE IF NOT EXISTS rentread CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE rentread;

-- Users table for storing user account information
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_email (email)
);

-- Books table for storing book information
CREATE TABLE IF NOT EXISTS books (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  filename VARCHAR(255) NOT NULL UNIQUE,
  author VARCHAR(255),
  price_per_day DECIMAL(10,2) DEFAULT 5.00,
  total_pages INT,
  category VARCHAR(100),
  is_available TINYINT(1) DEFAULT 1,
  image_url VARCHAR(500),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Indexes
  INDEX idx_filename (filename),
  INDEX idx_category (category),
  INDEX idx_available (is_available),
  INDEX idx_created_at (created_at)
);

-- Add image_url column if it doesn't exist (for existing databases)
ALTER TABLE books ADD COLUMN IF NOT EXISTS image_url VARCHAR(500);

-- Access records table for tracking book rentals
CREATE TABLE IF NOT EXISTS access_records (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  book_id INT NOT NULL,
  expires_at DATETIME NOT NULL,
  active TINYINT(1) DEFAULT 1,
  rental_days INT NOT NULL DEFAULT 1,
  total_cost DECIMAL(10,2) NOT NULL DEFAULT 5.00,
  payment_status ENUM('pending', 'paid', 'failed') DEFAULT 'paid',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign key constraints
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  
  -- Indexes for performance
  INDEX idx_user_id (user_id),
  INDEX idx_book_id (book_id),
  INDEX idx_user_active_expires (user_id, active, expires_at),
  INDEX idx_expires_at (expires_at),
  INDEX idx_active (active)
);

-- Sample book inserts with enhanced data
INSERT INTO books (title, description, filename, author, price_per_day, category, total_pages) VALUES
('The Great Gatsby', 'A classic American novel about the Jazz Age and the American Dream', 'great_gatsby.pdf', 'F. Scott Fitzgerald', 3.00, 'Fiction', 180),
('To Kill a Mockingbird', 'A gripping tale of racial injustice and loss of innocence in the American South', 'mockingbird.pdf', 'Harper Lee', 4.00, 'Fiction', 281),
('1984', 'George Orwell\'s dystopian masterpiece about totalitarian surveillance', '1984.pdf', 'George Orwell', 5.00, 'Science Fiction', 328),
('Pride and Prejudice', 'Jane Austen\'s beloved romance novel about Elizabeth Bennet and Mr. Darcy', 'pride_prejudice.pdf', 'Jane Austen', 3.50, 'Romance', 432),
('The Catcher in the Rye', 'J.D. Salinger\'s coming-of-age novel about Holden Caulfield', 'catcher_rye.pdf', 'J.D. Salinger', 4.50, 'Fiction', 234)
ON DUPLICATE KEY UPDATE 
  title = VALUES(title),
  description = VALUES(description),
  author = VALUES(author),
  price_per_day = VALUES(price_per_day),
  category = VALUES(category),
  total_pages = VALUES(total_pages);
