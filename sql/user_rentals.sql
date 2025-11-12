-- Enhanced user_rentals table with complete book information
-- This table will store all book details when user rents a book
CREATE TABLE IF NOT EXISTS `user_rentals` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `book_id` INT NULL,
  
  -- Basic rental information
  `book_title` VARCHAR(512) NOT NULL,
  `rental_days` INT NOT NULL DEFAULT 1,
  `total_price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `rental_date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expiry_date` DATETIME NOT NULL,
  `status` VARCHAR(32) DEFAULT 'active',
  `access_count` INT DEFAULT 0,
  `last_accessed` DATETIME NULL,
  
  -- Complete book information (copied from books table when renting)
  `title` VARCHAR(512) NOT NULL,
  `description` TEXT NULL,
  `author` VARCHAR(255) NULL,
  `price_per_day` DECIMAL(10,2) NULL,
  `total_pages` INT NULL,
  `category` VARCHAR(100) NULL,
  `is_available` TINYINT(1) DEFAULT 1,
  `filename` VARCHAR(255) NULL,
  `base_price` DECIMAL(10,2) NULL,
  `daily_increment` DECIMAL(10,2) NULL,
  `max_rental_days` INT NULL,
  `image_url` VARCHAR(500) NULL,
  `pdf_file` VARCHAR(500) NULL,
  `file_size` BIGINT NULL,
  `availability_status` VARCHAR(50) NULL,
  `total_rented` INT NULL,
  `language` VARCHAR(50) NULL,
  `drive_link` VARCHAR(500) NULL,
  
  -- Timestamps
  `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  PRIMARY KEY (`id`),
  INDEX (`user_id`),
  INDEX (`book_id`),
  INDEX (`status`),
  INDEX (`expiry_date`),
  INDEX (`rental_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add missing columns to existing table (if table already exists)
ALTER TABLE `user_rentals` 
  ADD COLUMN IF NOT EXISTS `last_accessed` DATETIME NULL AFTER `access_count`,
  ADD COLUMN IF NOT EXISTS `title` VARCHAR(512) NOT NULL AFTER `last_accessed`,
  ADD COLUMN IF NOT EXISTS `description` TEXT NULL AFTER `title`,
  ADD COLUMN IF NOT EXISTS `author` VARCHAR(255) NULL AFTER `description`,
  ADD COLUMN IF NOT EXISTS `price_per_day` DECIMAL(10,2) NULL AFTER `author`,
  ADD COLUMN IF NOT EXISTS `total_pages` INT NULL AFTER `price_per_day`,
  ADD COLUMN IF NOT EXISTS `category` VARCHAR(100) NULL AFTER `total_pages`,
  ADD COLUMN IF NOT EXISTS `is_available` TINYINT(1) DEFAULT 1 AFTER `category`,
  ADD COLUMN IF NOT EXISTS `filename` VARCHAR(255) NULL AFTER `is_available`,
  ADD COLUMN IF NOT EXISTS `base_price` DECIMAL(10,2) NULL AFTER `filename`,
  ADD COLUMN IF NOT EXISTS `daily_increment` DECIMAL(10,2) NULL AFTER `base_price`,
  ADD COLUMN IF NOT EXISTS `max_rental_days` INT NULL AFTER `daily_increment`,
  ADD COLUMN IF NOT EXISTS `image_url` VARCHAR(500) NULL AFTER `max_rental_days`,
  ADD COLUMN IF NOT EXISTS `pdf_file` VARCHAR(500) NULL AFTER `image_url`,
  ADD COLUMN IF NOT EXISTS `file_size` BIGINT NULL AFTER `pdf_file`,
  ADD COLUMN IF NOT EXISTS `availability_status` VARCHAR(50) NULL AFTER `file_size`,
  ADD COLUMN IF NOT EXISTS `total_rented` INT NULL AFTER `availability_status`,
  ADD COLUMN IF NOT EXISTS `language` VARCHAR(50) NULL AFTER `total_rented`,
  ADD COLUMN IF NOT EXISTS `drive_link` VARCHAR(500) NULL AFTER `language`,
  ADD COLUMN IF NOT EXISTS `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP AFTER `drive_link`,
  ADD COLUMN IF NOT EXISTS `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `created_at`;

-- Sample data insertion (optional - for testing)
-- INSERT INTO user_rentals (user_id, book_id, book_title, title, author, category, rental_days, total_price, expiry_date, image_url, pdf_file, drive_link)
-- VALUES (1, 1, 'Sample Book', 'Sample Book', 'Sample Author', 'Computer Science', 7, 52.00, DATE_ADD(NOW(), INTERVAL 7 DAY), '/img/sample.jpg', 'sample.pdf', 'https://drive.google.com/file/d/sample/view');

-- Note: This enhanced schema stores complete book information in user_rentals table
-- When user rents a book, all book details are copied to ensure data consistency
