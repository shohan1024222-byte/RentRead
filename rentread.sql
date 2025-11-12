-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 31, 2025 at 01:33 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.1.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `rentread`
--

-- --------------------------------------------------------

--
-- Table structure for table `access_records`
--

CREATE TABLE `access_records` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `book_id` int(11) NOT NULL,
  `expires_at` datetime NOT NULL,
  `active` tinyint(1) DEFAULT 1,
  `rental_days` int(11) NOT NULL DEFAULT 1,
  `total_cost` decimal(10,2) NOT NULL DEFAULT 5.00,
  `payment_status` enum('pending','paid','failed') DEFAULT 'paid',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `access_records`
--

INSERT INTO `access_records` (`id`, `user_id`, `book_id`, `expires_at`, `active`, `rental_days`, `total_cost`, `payment_status`, `created_at`) VALUES
(1, 2, 9, '2025-10-27 00:12:22', 0, 1, 5.00, 'paid', '2025-10-25 18:12:22'),
(2, 2, 1, '2025-11-01 18:19:53', 1, 1, 5.00, 'paid', '2025-10-31 12:19:53');

-- --------------------------------------------------------

--
-- Table structure for table `books`
--

CREATE TABLE `books` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `price_per_day` decimal(10,2) DEFAULT 5.00,
  `total_pages` int(11) DEFAULT NULL,
  `category` varchar(100) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT 1,
  `filename` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `base_price` decimal(8,2) DEFAULT 10.00,
  `daily_increment` decimal(5,2) DEFAULT 2.00,
  `max_rental_days` int(11) DEFAULT 30,
  `image_url` varchar(500) DEFAULT NULL,
  `pdf_file` varchar(255) DEFAULT NULL,
  `file_size` varchar(20) DEFAULT NULL,
  `availability_status` enum('available','maintenance','discontinued') DEFAULT 'available',
  `total_rented` int(11) DEFAULT 0,
  `language` varchar(50) DEFAULT 'Bangla',
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `books`
--

INSERT INTO `books` (`id`, `title`, `description`, `author`, `price_per_day`, `total_pages`, `category`, `is_available`, `filename`, `created_at`, `base_price`, `daily_increment`, `max_rental_days`, `image_url`, `pdf_file`, `file_size`, `availability_status`, `total_rented`, `language`, `updated_at`) VALUES
(1, 'Sample Book One', 'A demo PDF for RentRead', 'Unknown Author', 5.00, 200, 'Fiction', 1, 'sample1.pdf', '2025-10-25 11:01:03', 10.00, 2.00, 30, NULL, NULL, NULL, 'available', 0, 'Bangla', '2025-10-30 18:05:08'),
(4, 'Sample Book One', 'A demo PDF for RentRead', 'Unknown Author', 5.00, 200, 'Fiction', 1, 'sample1.pdf', '2025-10-25 11:09:40', 10.00, 2.00, 30, NULL, NULL, NULL, 'available', 0, 'Bangla', '2025-10-30 18:05:08'),
(5, 'The Great Gatsby', 'A classic American novel about the Jazz Age and the American Dream', 'F. Scott Fitzgerald', 3.00, 180, 'Fiction', 1, 'great_gatsby.pdf', '2025-10-25 18:01:48', 10.00, 2.00, 30, NULL, NULL, NULL, 'available', 0, 'Bangla', '2025-10-30 18:05:08'),
(6, 'To Kill a Mockingbird', 'A gripping tale of racial injustice and loss of innocence in the American South', 'Harper Lee', 4.00, 281, 'Fiction', 1, 'mockingbird.pdf', '2025-10-25 18:01:48', 10.00, 2.00, 30, NULL, NULL, NULL, 'available', 0, 'Bangla', '2025-10-30 18:05:08'),
(7, '1984', 'George Orwell\'s dystopian masterpiece about totalitarian surveillance', 'George Orwell', 5.00, 328, 'Science Fiction', 1, '1984.pdf', '2025-10-25 18:01:48', 10.00, 2.00, 30, NULL, NULL, NULL, 'available', 0, 'Bangla', '2025-10-30 18:05:08'),
(8, 'Pride and Prejudice', 'Jane Austen\'s beloved romance novel about Elizabeth Bennet and Mr. Darcy', 'Jane Austen', 3.50, 432, 'Romance', 1, 'pride_prejudice.pdf', '2025-10-25 18:01:48', 10.00, 2.00, 30, NULL, NULL, NULL, 'available', 0, 'Bangla', '2025-10-30 18:05:08'),
(9, 'The Catcher in the Rye', 'J.D. Salinger\'s coming-of-age novel about Holden Caulfield', 'J.D. Salinger', 4.50, 234, 'Fiction', 1, 'catcher_rye.pdf', '2025-10-25 18:01:48', 10.00, 2.00, 30, NULL, NULL, NULL, 'available', 0, 'Bangla', '2025-10-30 18:05:08');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `phone` varchar(20) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('active','inactive','suspended') DEFAULT 'active',
  `total_rentals` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `created_at`, `phone`, `address`, `registration_date`, `status`, `total_rentals`) VALUES
(1, 'Test User', 'testuser@example.com', '$2a$10$OrLTnUdASb6Y3dA6loF9f.00tKV.SQln/.PwWivZYDerpnWyjhR.q', '2025-10-25 12:46:40', NULL, NULL, '2025-10-30 18:05:08', 'active', 0),
(2, 'Shohan', 'shohan1024222@gmail.com', '$2a$10$0HMsxB8TA4KFM5WIGo.ogephkPM0/XPs7KJpie552Ch9/MD0U6uiy', '2025-10-25 17:32:08', NULL, NULL, '2025-10-30 18:05:08', 'active', 0);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `access_records`
--
ALTER TABLE `access_records`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_book_id` (`book_id`),
  ADD KEY `idx_expires_at` (`expires_at`),
  ADD KEY `idx_active` (`active`);

--
-- Indexes for table `books`
--
ALTER TABLE `books`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_filename` (`filename`),
  ADD KEY `idx_category` (`category`),
  ADD KEY `idx_available` (`is_available`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `access_records`
--
ALTER TABLE `access_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `books`
--
ALTER TABLE `books`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `access_records`
--
ALTER TABLE `access_records`
  ADD CONSTRAINT `access_records_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `access_records_ibfk_2` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
