-- SQL to create user_rentals table with all book information
-- This table will store complete book details when user rents a book

CREATE TABLE `user_rentals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `book_id` int(11) DEFAULT NULL,
  
  -- Rental specific fields
  `rental_days` int(11) NOT NULL DEFAULT 1,
  `total_price` decimal(10,2) NOT NULL DEFAULT 0.00,
  `rental_date` datetime NOT NULL DEFAULT current_timestamp(),
  `expiry_date` datetime NOT NULL,
  `status` varchar(32) DEFAULT 'active',
  `access_count` int(11) DEFAULT 0,
  `last_accessed` datetime DEFAULT NULL,
  
  -- Complete book information (copied from books table)
  `title` varchar(512) NOT NULL,
  `description` text DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `price_per_day` decimal(10,2) DEFAULT NULL,
  `total_pages` int(11) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `filename` varchar(255) DEFAULT NULL,
  `base_price` decimal(10,2) DEFAULT NULL,
  `daily_increment` decimal(10,2) DEFAULT NULL,
  `max_rental_days` int(11) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `pdf_file` varchar(500) DEFAULT NULL,
  `file_size` bigint(20) DEFAULT NULL,
  `availability_status` varchar(50) DEFAULT NULL,
  `total_rented` int(11) DEFAULT NULL,
  `language` varchar(50) DEFAULT NULL,
  `drive_link` varchar(500) DEFAULT NULL,
  
  -- Timestamp fields
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_book_id` (`book_id`),
  KEY `idx_status` (`status`),
  KEY `idx_expiry_date` (`expiry_date`),
  
  -- Foreign key constraint
  CONSTRAINT `user_rentals_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_rentals_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create indexes for better performance
CREATE INDEX `idx_user_rental_status` ON `user_rentals` (`user_id`, `status`);
CREATE INDEX `idx_user_rental_date` ON `user_rentals` (`user_id`, `rental_date`);
CREATE INDEX `idx_book_title` ON `user_rentals` (`title`);