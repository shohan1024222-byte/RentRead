-- Simple RentRead Database Setup for XAMPP
-- Copy and paste this entire script in phpMyAdmin SQL tab

-- Use existing rentread database
USE `rentread`;

-- Add new columns to existing users table (if not exists)
ALTER TABLE `users` 
ADD COLUMN IF NOT EXISTS `phone` VARCHAR(20),
ADD COLUMN IF NOT EXISTS `address` TEXT,
ADD COLUMN IF NOT EXISTS `registration_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS `status` ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
ADD COLUMN IF NOT EXISTS `total_rentals` INT DEFAULT 0;

-- Add new columns to existing books table (if not exists)
ALTER TABLE `books` 
ADD COLUMN IF NOT EXISTS `base_price` DECIMAL(8,2) DEFAULT 10.00,
ADD COLUMN IF NOT EXISTS `daily_increment` DECIMAL(5,2) DEFAULT 2.00,
ADD COLUMN IF NOT EXISTS `max_rental_days` INT DEFAULT 30,
ADD COLUMN IF NOT EXISTS `image_url` VARCHAR(500),
ADD COLUMN IF NOT EXISTS `pdf_file` VARCHAR(255),
ADD COLUMN IF NOT EXISTS `file_size` VARCHAR(20),
ADD COLUMN IF NOT EXISTS `availability_status` ENUM('available', 'maintenance', 'discontinued') DEFAULT 'available',
ADD COLUMN IF NOT EXISTS `total_rented` INT DEFAULT 0,
ADD COLUMN IF NOT EXISTS `language` VARCHAR(50) DEFAULT 'Bangla',
ADD COLUMN IF NOT EXISTS `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Create user_rentals table
CREATE TABLE IF NOT EXISTS `user_rentals` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `book_id` INT NOT NULL,
  `book_title` VARCHAR(500) NOT NULL,
  `rental_days` INT NOT NULL,
  `base_price` DECIMAL(8,2) NOT NULL,
  `daily_increment` DECIMAL(5,2) NOT NULL,
  `total_price` DECIMAL(10,2) NOT NULL,
  `rental_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `expiry_date` TIMESTAMP NOT NULL,
  `status` ENUM('active', 'expired', 'returned', 'extended') DEFAULT 'active',
  `payment_status` ENUM('pending', 'paid', 'refunded') DEFAULT 'paid',
  `access_count` INT DEFAULT 0,
  `last_accessed` TIMESTAMP NULL,
  `notes` TEXT,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_book_id` (`book_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_expiry_date` (`expiry_date`),
  INDEX `idx_rental_date` (`rental_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create rental_history table
CREATE TABLE IF NOT EXISTS `rental_history` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `book_id` INT NOT NULL,
  `rental_id` INT NOT NULL,
  `action_type` ENUM('rented', 'accessed', 'returned', 'expired', 'extended') NOT NULL,
  `action_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `details` JSON,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_book_id` (`book_id`),
  INDEX `idx_action_type` (`action_type`),
  INDEX `idx_action_date` (`action_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create book_categories table
CREATE TABLE IF NOT EXISTS `book_categories` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) UNIQUE NOT NULL,
  `description` TEXT,
  `icon` VARCHAR(50),
  `sort_order` INT DEFAULT 0,
  `status` ENUM('active', 'inactive') DEFAULT 'active',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default categories
INSERT IGNORE INTO `book_categories` (`name`, `description`, `icon`, `sort_order`) VALUES
('Computer Science', 'Programming, algorithms, data structures, databases', '💻', 1),
('General Science', 'Physics, Chemistry, Biology, Mathematics', '🔬', 2),
('Science Fiction', 'Sci-fi novels and stories in Bangla', '🚀', 3),
('Extra Educational', 'Language learning, ICT, AI, additional skills', '📚', 4);

-- Update existing books with new pricing and details
UPDATE `books` SET 
  `base_price` = 15.00, 
  `daily_increment` = 2.00, 
  `category` = 'Computer Science',
  `language` = 'English',
  `image_url` = 'https://rokomari.com/static/images/books/c_programming.jpg'
WHERE `title` LIKE '%C Programming%' OR `title` LIKE '%programming%';

UPDATE `books` SET 
  `base_price` = 6.00, 
  `daily_increment` = 2.00, 
  `category` = 'Science Fiction',
  `language` = 'Bangla',
  `image_url` = 'https://rokomari.com/static/images/books/scifi.jpg'
WHERE `category` = 'Science Fiction';

UPDATE `books` SET 
  `base_price` = 5.00, 
  `daily_increment` = 2.00, 
  `language` = 'English',
  `image_url` = 'https://rokomari.com/static/images/books/fiction.jpg'
WHERE `category` = 'Fiction';

-- Insert sample enhanced books (if they don't exist)
INSERT IGNORE INTO `books` (`title`, `author`, `category`, `language`, `base_price`, `daily_increment`, `image_url`, `description`, `filename`) VALUES
-- Computer Science Books
('C Programming', 'Dennis Ritchie', 'Computer Science', 'English', 15.00, 2.00, 'https://rokomari.com/static/images/books/c_programming.jpg', 'Complete guide to C programming language', 'c_programming.pdf'),
('Data Structure', 'Various Authors', 'Computer Science', 'English', 18.00, 2.00, 'https://rokomari.com/static/images/books/data_structure.jpg', 'Data structures and algorithms', 'data_structure.pdf'),
('Algorithm', 'Thomas Cormen', 'Computer Science', 'English', 20.00, 2.00, 'https://rokomari.com/static/images/books/algorithm.jpg', 'Introduction to algorithms', 'algorithm.pdf'),
('Database', 'Various Authors', 'Computer Science', 'English', 16.00, 2.00, 'https://rokomari.com/static/images/books/database.jpg', 'Database management systems', 'database.pdf'),
('Operating System', 'Abraham Silberschatz', 'Computer Science', 'English', 14.00, 2.00, 'https://rokomari.com/static/images/books/os.jpg', 'Operating system concepts', 'os.pdf'),
('Networking', 'James Kurose', 'Computer Science', 'English', 18.00, 2.00, 'https://rokomari.com/static/images/books/networking.jpg', 'Computer networking fundamentals', 'networking.pdf'),

-- General Science Books
('Physics', 'Various Authors', 'General Science', 'English', 12.00, 2.00, 'https://rokomari.com/static/images/books/physics.jpg', 'Fundamentals of physics', 'physics.pdf'),
('Chemistry', 'Various Authors', 'General Science', 'English', 10.00, 2.00, 'https://rokomari.com/static/images/books/chemistry.jpg', 'Basic chemistry concepts', 'chemistry.pdf'),
('Biology', 'Various Authors', 'General Science', 'English', 15.00, 2.00, 'https://rokomari.com/static/images/books/biology.jpg', 'Biological science fundamentals', 'biology.pdf'),
('Mathematics', 'Various Authors', 'General Science', 'English', 16.00, 2.00, 'https://rokomari.com/static/images/books/math.jpg', 'Mathematical concepts and applications', 'math.pdf'),

-- Science Fiction Books
('রোবট সমগ্র - হুমায়ূন আহমেদ', 'হুমায়ূন আহমেদ', 'Science Fiction', 'Bangla', 6.00, 2.00, 'https://rokomari.com/static/images/books/robot_humayun.jpg', 'Collection of robot stories by Humayun Ahmed', 'robot_humayun.pdf'),
('সহকারী রোবট', 'Various Authors', 'Science Fiction', 'Bangla', 5.00, 2.00, 'https://rokomari.com/static/images/books/sohokari_robot.jpg', 'Assistant robot science fiction', 'sohokari_robot.pdf'),
('কালো গহ্বরের গল্প', 'Various Authors', 'Science Fiction', 'Bangla', 7.00, 2.00, 'https://rokomari.com/static/images/books/blackhole.jpg', 'Black hole science fiction stories', 'blackhole.pdf'),
('সহজ বিজ্ঞান কল্পকাহিনী', 'Various Authors', 'Science Fiction', 'Bangla', 8.00, 2.00, 'https://rokomari.com/static/images/books/scifi_simple.jpg', 'Easy science fiction stories', 'scifi_simple.pdf'),
('বিজ্ঞান কল্পকাহিনী সমগ্র', 'Various Authors', 'Science Fiction', 'Bangla', 9.00, 2.00, 'https://rokomari.com/static/images/books/scifi_collection.jpg', 'Complete science fiction collection', 'scifi_collection.pdf'),

-- Extra Educational Books
('English Grammar', 'Various Authors', 'Extra Educational', 'English', 6.00, 2.00, 'https://rokomari.com/static/images/books/english_grammar.jpg', 'Complete English grammar guide', 'english_grammar.pdf'),
('ICT for Beginners', 'Various Authors', 'Extra Educational', 'English', 8.00, 2.00, 'https://rokomari.com/static/images/books/ict.jpg', 'Information and communication technology basics', 'ict.pdf'),
('Learn Programming', 'Various Authors', 'Extra Educational', 'English', 12.00, 2.00, 'https://rokomari.com/static/images/books/programming.jpg', 'Programming fundamentals for beginners', 'programming.pdf'),
('Artificial Intelligence Basics', 'Various Authors', 'Extra Educational', 'English', 15.00, 2.00, 'https://rokomari.com/static/images/books/ai.jpg', 'Introduction to artificial intelligence', 'ai.pdf');

-- Create view for active rentals
CREATE OR REPLACE VIEW `active_rentals` AS
SELECT 
    ur.id as rental_id,
    u.name as user_name,
    u.email as user_email,
    b.title as book_title,
    b.category as book_category,
    ur.rental_days,
    ur.total_price,
    ur.rental_date,
    ur.expiry_date,
    ur.access_count,
    DATEDIFF(ur.expiry_date, NOW()) as days_remaining
FROM user_rentals ur
JOIN users u ON ur.user_id = u.id
JOIN books b ON ur.book_id = b.id
WHERE ur.status = 'active' AND ur.expiry_date > NOW();

-- Create view for user rental summary
CREATE OR REPLACE VIEW `user_rental_summary` AS
SELECT 
    u.id as user_id,
    u.name as user_name,
    u.email as user_email,
    COUNT(ur.id) as total_rentals,
    COUNT(CASE WHEN ur.status = 'active' THEN 1 END) as active_rentals,
    COALESCE(SUM(ur.total_price), 0) as total_spent,
    MAX(ur.rental_date) as last_rental_date
FROM users u
LEFT JOIN user_rentals ur ON u.id = ur.user_id
GROUP BY u.id, u.name, u.email;

-- Add indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_book_category ON books(category);
CREATE INDEX IF NOT EXISTS idx_rental_user_book ON user_rentals(user_id, book_id);
CREATE INDEX IF NOT EXISTS idx_rental_status ON user_rentals(status);
CREATE INDEX IF NOT EXISTS idx_rental_expiry ON user_rentals(expiry_date);

-- Success message
SELECT 'Database setup completed successfully!' as message;
SELECT 'Enhanced tables created and sample data inserted' as status;
SELECT COUNT(*) as total_books FROM books;
SELECT COUNT(*) as total_categories FROM book_categories;