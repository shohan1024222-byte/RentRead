-- Create user_book table for recording rentals per user
-- Columns: id (auto), email, password_hash, book_name, days, price, created_at

CREATE TABLE IF NOT EXISTS `user_book` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(255) NULL,
  `password_hash` VARCHAR(255) NULL,
  `book_name` VARCHAR(512) NOT NULL,
  `days` INT NOT NULL DEFAULT 1,
  `price` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
