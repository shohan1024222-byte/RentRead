# RentRead Database Schema Documentation

## Overview
RentRead is a book rental system where users can register, browse books, and rent them for a specified duration. The system tracks user access and rental periods.

## Database Structure

### 1. `users` Table
Stores user account information.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | Unique user identifier |
| `name` | VARCHAR(255) | NOT NULL | User's full name |
| `email` | VARCHAR(255) | UNIQUE, NOT NULL | User's email address (used for login) |
| `password_hash` | VARCHAR(255) | NOT NULL | Hashed password for security |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Account creation time |

**Indexes:**
- Primary key on `id`
- Unique index on `email`

### 2. `books` Table
Stores information about available books.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | Unique book identifier |
| `title` | VARCHAR(255) | NOT NULL | Book title |
| `description` | TEXT | NULL | Book description/summary |
| `filename` | VARCHAR(255) | NOT NULL, UNIQUE | Actual file name in storage/books directory |
| `author` | VARCHAR(255) | NULL | Book author name |
| `price_per_day` | DECIMAL(10,2) | DEFAULT 5.00 | Daily rental price |
| `total_pages` | INT | NULL | Number of pages in the book |
| `category` | VARCHAR(100) | NULL | Book category/genre |
| `is_available` | TINYINT(1) | DEFAULT 1 | Whether book is available for rent |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | When book was added |

**Indexes:**
- Primary key on `id`
- Unique index on `filename`
- Index on `category` for filtering
- Index on `is_available` for quick availability checks

### 3. `access_records` Table (Rental Records)
Tracks user book rentals and access permissions.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| `id` | INT | PRIMARY KEY, AUTO_INCREMENT | Unique rental record identifier |
| `user_id` | INT | NOT NULL, FOREIGN KEY | References users.id |
| `book_id` | INT | NOT NULL, FOREIGN KEY | References books.id |
| `expires_at` | DATETIME | NOT NULL | When the rental expires |
| `active` | TINYINT(1) | DEFAULT 1 | Whether rental is still active |
| `rental_days` | INT | NOT NULL | Number of days rented |
| `total_cost` | DECIMAL(10,2) | NOT NULL | Total cost paid for rental |
| `payment_status` | ENUM('pending', 'paid', 'failed') | DEFAULT 'paid' | Payment status |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | When rental was created |

**Foreign Key Constraints:**
- `user_id` REFERENCES `users(id)` ON DELETE CASCADE
- `book_id` REFERENCES `books(id)` ON DELETE CASCADE

**Indexes:**
- Primary key on `id`
- Index on `user_id` for quick user rental lookups
- Index on `book_id` for book rental history
- Composite index on `(user_id, active, expires_at)` for active rental queries
- Index on `expires_at` for cleanup of expired rentals

## Business Logic

### Rental Process
1. User must be authenticated to rent books
2. User selects a book and specifies rental duration (1-30 days)
3. System creates an `access_records` entry with:
   - Current user ID
   - Selected book ID
   - Expiration date (current date + rental days)
   - Active status = 1
   - Total cost calculation
4. User can download/access the book while rental is active and not expired

### Access Control
- Users can only download books they have active, non-expired rentals for
- System checks `access_records` table for valid rental before allowing download
- Query: `SELECT * FROM access_records WHERE user_id=? AND book_id=? AND active=1 AND expires_at > NOW()`

### Rental Status
- **Active**: `active=1` AND `expires_at > NOW()`
- **Expired**: `active=1` AND `expires_at <= NOW()`
- **Cancelled**: `active=0`

## API Endpoints

### Books
- `GET /api/books` - List all available books
- `GET /api/books/download/:bookId` - Download book (requires active rental)

### Rentals
- `POST /api/rent` - Create new rental
  - Body: `{ bookId: number, days: number }`
  - Returns: `{ success: boolean, accessId: number, expiresInDays: number }`
- `GET /api/rent/my` - Get user's rental history
  - Returns: Array of rental records with book details

### Authentication
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout

## Sample Queries

### Get User's Active Rentals
```sql
SELECT 
    a.id, 
    a.book_id, 
    a.expires_at, 
    a.rental_days,
    a.total_cost,
    b.title, 
    b.description,
    b.filename,
    CASE 
        WHEN a.expires_at > NOW() THEN 'active'
        ELSE 'expired'
    END as status,
    DATEDIFF(a.expires_at, NOW()) as days_remaining
FROM access_records a 
JOIN books b ON a.book_id = b.id 
WHERE a.user_id = ? AND a.active = 1
ORDER BY a.expires_at DESC;
```

### Check Book Availability
```sql
SELECT id, title, price_per_day 
FROM books 
WHERE is_available = 1
ORDER BY created_at DESC;
```

### Validate Rental Access
```sql
SELECT a.*, b.filename, b.title 
FROM access_records a 
JOIN books b ON a.book_id = b.id
WHERE a.user_id = ? 
  AND a.book_id = ? 
  AND a.active = 1 
  AND a.expires_at > NOW();
```

## File Storage Structure
```
storage/
└── books/
    ├── book1.pdf
    ├── book2.pdf
    └── readme.txt
```

Books are stored as files in the `storage/books` directory. The `filename` field in the `books` table corresponds to the actual file name.

## Security Considerations
1. Passwords are hashed before storage
2. JWT tokens used for authentication
3. File access is protected by rental validation
4. User input is sanitized to prevent SQL injection
5. File downloads are validated against active rentals

## Performance Optimizations
1. Proper indexing on frequently queried columns
2. Composite indexes for complex queries
3. Cleanup script for expired rentals (see utils/cleanup.js)
4. File serving optimized for concurrent downloads