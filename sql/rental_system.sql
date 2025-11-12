-- RentRead Enhanced Database Schema for Rental System
-- Run this in XAMPP phpMyAdmin or MySQL command line

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS rentread_db;
USE rentread_db;

-- Users table (enhanced)
CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
  total_rentals INT DEFAULT 0,
  INDEX idx_email (email),
  INDEX idx_status (status)
);

-- Books table (enhanced with rental info)
CREATE TABLE IF NOT EXISTS books (
  id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(500) NOT NULL,
  author VARCHAR(255),
  category VARCHAR(100) NOT NULL,
  language VARCHAR(50) DEFAULT 'Bangla',
  description TEXT,
  base_price DECIMAL(8,2) NOT NULL DEFAULT 10.00,
  daily_increment DECIMAL(5,2) DEFAULT 2.00,
  max_rental_days INT DEFAULT 30,
  image_url VARCHAR(500),
  pdf_file VARCHAR(255),
  total_pages INT,
  file_size VARCHAR(20),
  availability_status ENUM('available', 'maintenance', 'discontinued') DEFAULT 'available',
  total_rented INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_category (category),
  INDEX idx_language (language),
  INDEX idx_availability (availability_status)
);

-- User rentals table
CREATE TABLE IF NOT EXISTS user_rentals (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  book_id INT NOT NULL,
  book_title VARCHAR(500) NOT NULL,
  rental_days INT NOT NULL,
  base_price DECIMAL(8,2) NOT NULL,
  daily_increment DECIMAL(5,2) NOT NULL,
  total_price DECIMAL(10,2) NOT NULL,
  rental_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  expiry_date TIMESTAMP NOT NULL,
  status ENUM('active', 'expired', 'returned', 'extended') DEFAULT 'active',
  payment_status ENUM('pending', 'paid', 'refunded') DEFAULT 'paid',
  access_count INT DEFAULT 0,
  last_accessed TIMESTAMP NULL,
  notes TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_book_id (book_id),
  INDEX idx_status (status),
  INDEX idx_expiry_date (expiry_date),
  INDEX idx_rental_date (rental_date)
);

-- Rental history table for analytics
CREATE TABLE IF NOT EXISTS rental_history (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  book_id INT NOT NULL,
  rental_id INT NOT NULL,
  action_type ENUM('rented', 'accessed', 'returned', 'expired', 'extended') NOT NULL,
  action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  details JSON,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE CASCADE,
  FOREIGN KEY (rental_id) REFERENCES user_rentals(id) ON DELETE CASCADE,
  INDEX idx_user_id (user_id),
  INDEX idx_book_id (book_id),
  INDEX idx_action_type (action_type),
  INDEX idx_action_date (action_date)
);

-- Book categories table for organization
CREATE TABLE IF NOT EXISTS book_categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) UNIQUE NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  sort_order INT DEFAULT 0,
  status ENUM('active', 'inactive') DEFAULT 'active',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default categories
INSERT IGNORE INTO book_categories (name, description, icon, sort_order) VALUES
('Computer Science', 'Programming, algorithms, data structures, databases', '💻', 1),
('General Science', 'Physics, Chemistry, Biology, Mathematics', '🔬', 2),
('Science Fiction', 'Sci-fi novels and stories in Bangla', '🚀', 3),
('Extra Educational', 'Language learning, ICT, AI, additional skills', '📚', 4);

-- Insert sample books (matching current index.html data)
INSERT IGNORE INTO books (title, author, category, language, base_price, daily_increment, image_url, description) VALUES
-- Computer Science Books
('C Programming', 'Dennis Ritchie', 'Computer Science', 'English', 15.00, 2.00, 'https://rokomari.com/static/images/books/c_programming.jpg', 'Complete guide to C programming language'),
('Data Structure', 'Various Authors', 'Computer Science', 'English', 18.00, 2.00, 'https://rokomari.com/static/images/books/data_structure.jpg', 'Data structures and algorithms'),
('Algorithm', 'Thomas Cormen', 'Computer Science', 'English', 20.00, 2.00, 'https://rokomari.com/static/images/books/algorithm.jpg', 'Introduction to algorithms'),
('Database', 'Various Authors', 'Computer Science', 'English', 16.00, 2.00, 'https://rokomari.com/static/images/books/database.jpg', 'Database management systems'),
('Operating System', 'Abraham Silberschatz', 'Computer Science', 'English', 14.00, 2.00, 'https://rokomari.com/static/images/books/os.jpg', 'Operating system concepts'),
('Networking', 'James Kurose', 'Computer Science', 'English', 18.00, 2.00, 'https://rokomari.com/static/images/books/networking.jpg', 'Computer networking fundamentals'),

-- General Science Books
('Physics', 'Various Authors', 'General Science', 'English', 12.00, 2.00, 'https://rokomari.com/static/images/books/physics.jpg', 'Fundamentals of physics'),
('Chemistry', 'Various Authors', 'General Science', 'English', 10.00, 2.00, 'https://rokomari.com/static/images/books/chemistry.jpg', 'Basic chemistry concepts'),
('Biology', 'Various Authors', 'General Science', 'English', 15.00, 2.00, 'https://rokomari.com/static/images/books/biology.jpg', 'Biological science fundamentals'),
('Mathematics', 'Various Authors', 'General Science', 'English', 16.00, 2.00, 'https://rokomari.com/static/images/books/math.jpg', 'Mathematical concepts and applications'),

-- Science Fiction Books
('রোবট সমগ্র - হুমায়ূন আহমেদ', 'হুমায়ূন আহমেদ', 'Science Fiction', 'Bangla', 6.00, 2.00, 'https://rokomari.com/static/images/books/robot_humayun.jpg', 'Collection of robot stories by Humayun Ahmed'),
('সহকারী রোবট', 'Various Authors', 'Science Fiction', 'Bangla', 5.00, 2.00, 'https://rokomari.com/static/images/books/sohokari_robot.jpg', 'Assistant robot science fiction'),
('কালো গহ্বরের গল্প', 'Various Authors', 'Science Fiction', 'Bangla', 7.00, 2.00, 'https://rokomari.com/static/images/books/blackhole.jpg', 'Black hole science fiction stories'),
('সহজ বিজ্ঞান কল্পকাহিনী', 'Various Authors', 'Science Fiction', 'Bangla', 8.00, 2.00, 'https://rokomari.com/static/images/books/scifi_simple.jpg', 'Easy science fiction stories'),
('বিজ্ঞান কল্পকাহিনী সমগ্র', 'Various Authors', 'Science Fiction', 'Bangla', 9.00, 2.00, 'https://rokomari.com/static/images/books/scifi_collection.jpg', 'Complete science fiction collection'),

-- Extra Educational Books
('English Grammar', 'Various Authors', 'Extra Educational', 'English', 6.00, 2.00, 'https://rokomari.com/static/images/books/english_grammar.jpg', 'Complete English grammar guide'),
('ICT for Beginners', 'Various Authors', 'Extra Educational', 'English', 8.00, 2.00, 'https://rokomari.com/static/images/books/ict.jpg', 'Information and communication technology basics'),
('Learn Programming', 'Various Authors', 'Extra Educational', 'English', 12.00, 2.00, 'https://rokomari.com/static/images/books/programming.jpg', 'Programming fundamentals for beginners'),
('Artificial Intelligence Basics', 'Various Authors', 'Extra Educational', 'English', 15.00, 2.00, 'https://rokomari.com/static/images/books/ai.jpg', 'Introduction to artificial intelligence');

-- Create indexes for better performance
CREATE INDEX idx_user_email ON users(email);
CREATE INDEX idx_book_category ON books(category);
CREATE INDEX idx_rental_user_book ON user_rentals(user_id, book_id);
CREATE INDEX idx_rental_status ON user_rentals(status);
CREATE INDEX idx_rental_expiry ON user_rentals(expiry_date);

-- Create views for easy data retrieval
CREATE VIEW active_rentals AS
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
CREATE VIEW user_rental_summary AS
SELECT 
    u.id as user_id,
    u.name as user_name,
    u.email as user_email,
    COUNT(ur.id) as total_rentals,
    COUNT(CASE WHEN ur.status = 'active' THEN 1 END) as active_rentals,
    SUM(ur.total_price) as total_spent,
    MAX(ur.rental_date) as last_rental_date
FROM users u
LEFT JOIN user_rentals ur ON u.id = ur.user_id
GROUP BY u.id, u.name, u.email;

-- Sample admin user (password: admin123)
INSERT IGNORE INTO users (name, email, password, status) VALUES 
('Admin User', 'admin@rentread.com', '$2b$10$K8J9Z1XfzXQmOK5n3F2p7O8H6U4W2E1V5G3N9T7A2C0S8M4Q1B6R9', 'active');

-- Create stored procedure for processing rentals
DELIMITER //
CREATE PROCEDURE ProcessBookRental(
    IN p_user_id INT,
    IN p_book_id INT,
    IN p_rental_days INT,
    OUT p_rental_id INT,
    OUT p_total_price DECIMAL(10,2),
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_base_price DECIMAL(8,2);
    DECLARE v_daily_increment DECIMAL(5,2);
    DECLARE v_book_title VARCHAR(500);
    DECLARE v_expiry_date TIMESTAMP;
    DECLARE v_max_days INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION 
    BEGIN
        ROLLBACK;
        SET p_success = FALSE;
        SET p_message = 'Database error occurred';
    END;
    
    START TRANSACTION;
    
    -- Get book details
    SELECT base_price, daily_increment, title, max_rental_days
    INTO v_base_price, v_daily_increment, v_book_title, v_max_days
    FROM books 
    WHERE id = p_book_id AND availability_status = 'available';
    
    -- Check if book exists and is available
    IF v_base_price IS NULL THEN
        SET p_success = FALSE;
        SET p_message = 'Book not found or not available';
        ROLLBACK;
    ELSE
        -- Check rental days limit
        IF p_rental_days > v_max_days THEN
            SET p_success = FALSE;
            SET p_message = CONCAT('Maximum rental period is ', v_max_days, ' days');
            ROLLBACK;
        ELSE
            -- Calculate total price
            SET p_total_price = v_base_price + ((p_rental_days - 1) * v_daily_increment);
            
            -- Calculate expiry date
            SET v_expiry_date = DATE_ADD(NOW(), INTERVAL p_rental_days DAY);
            
            -- Insert rental record
            INSERT INTO user_rentals (
                user_id, book_id, book_title, rental_days, 
                base_price, daily_increment, total_price, expiry_date
            ) VALUES (
                p_user_id, p_book_id, v_book_title, p_rental_days,
                v_base_price, v_daily_increment, p_total_price, v_expiry_date
            );
            
            SET p_rental_id = LAST_INSERT_ID();
            
            -- Update book statistics
            UPDATE books SET total_rented = total_rented + 1 WHERE id = p_book_id;
            
            -- Update user statistics
            UPDATE users SET total_rentals = total_rentals + 1 WHERE id = p_user_id;
            
            -- Add to rental history
            INSERT INTO rental_history (user_id, book_id, rental_id, action_type, details)
            VALUES (p_user_id, p_book_id, p_rental_id, 'rented', 
                    JSON_OBJECT('days', p_rental_days, 'price', p_total_price));
            
            SET p_success = TRUE;
            SET p_message = 'Rental processed successfully';
            
            COMMIT;
        END IF;
    END IF;
END //
DELIMITER ;

-- Show database creation summary
SELECT 'Database setup completed successfully!' as message;
SELECT 'Tables created:' as info, 'users, books, user_rentals, rental_history, book_categories' as tables;
SELECT 'Sample data inserted for' as info, COUNT(*) as total_books FROM books;
SELECT 'Views created:' as info, 'active_rentals, user_rental_summary' as views;
SELECT 'Stored procedure created:' as info, 'ProcessBookRental' as procedure_name;