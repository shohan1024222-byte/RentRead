# RentRead - Enhanced PDF Book Rental System

🚀 **Complete book rental system with dynamic pricing, user management, and rental tracking**

## ✨ New Features Added

### 🎯 Dynamic Rental System
- **Modal-based rental selection** - Click "Rent Now" to choose rental duration
- **Dynamic pricing calculation** - Base price + incremental cost per extra day
- **Flexible rental periods** - 1-30 days with custom pricing
- **Real-time price updates** - See total cost as you select days

### 👥 Enhanced User Management
- **Seamless registration/login** - Auto-process pending rentals after auth
- **User-specific dashboards** - View all your rented books
- **Rental history tracking** - Complete rental and access logs
- **Multi-user support** - Each user has their own rental collection

### 📊 Advanced Database System
- **Comprehensive SQL schema** - Users, books, rentals, history tables
- **Automated rental expiry** - Background job handles expiration
- **Access tracking** - Monitor book usage and reading patterns
- **Rental analytics** - Views for easy data retrieval

## 🛠️ Installation & Setup

### 1. Prerequisites
- **XAMPP** (for MySQL database)
- **Node.js** (v16 or higher)
- **Web browser** (Chrome, Firefox, etc.)

### 2. Database Setup

1. **Start XAMPP** and enable MySQL
2. **Open phpMyAdmin** (http://localhost/phpmyadmin)
3. **Import database**:
   ```sql
   -- Run the SQL script in sql/rental_system.sql
   -- This will create all necessary tables and sample data
   ```

### 3. Environment Configuration

Create a `.env` file in the root directory:
```env
# Database Configuration
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=
DB_NAME=rentread_db

# JWT Secret (change this!)
JWT_SECRET=your-super-secret-jwt-key-here

# Server Configuration
PORT=4000
```

### 4. Install Dependencies

```bash
# In the project directory
npm install
```

### 5. Start the Server

```bash
# Development mode with auto-restart
npm run dev

# Or production mode
npm start
```

## 🎮 How to Use

### For Users:

1. **Browse Books**: Visit http://localhost:4000
2. **Select Duration**: Click "Rent Now" → Choose days (1-30)
3. **See Dynamic Pricing**: Base price + ৳2 per extra day
4. **Register/Login**: Create account or login to existing one
5. **Automatic Rental**: Book gets added to your account instantly
6. **Access Dashboard**: View all your rented books
7. **Read Books**: Click "Read Now" for active rentals

### Pricing Examples:
- **1 day**: Base price (৳5-20 depending on book)
- **3 days**: Base price + ৳4 extra
- **7 days**: Base price + ৳12 extra
- **30 days**: Base price + ৳58 extra

## 🗄️ Database Schema

### Core Tables:
- **`users`** - User accounts and statistics
- **`books`** - Book catalog with pricing info
- **`user_rentals`** - Active and expired rentals
- **`rental_history`** - Complete audit trail
- **`book_categories`** - Book organization

### Key Features:
- **Stored Procedures** - `ProcessBookRental` for complex rental logic
- **Views** - `active_rentals`, `user_rental_summary` for easy queries
- **Indexes** - Optimized for fast queries
- **Foreign Keys** - Data integrity protection

## 🔧 API Endpoints

### Authentication:
- `POST /api/auth/register` - User registration
- `POST /api/auth/login` - User login

### Rentals:
- `POST /api/rent-book` - Process new rental
- `GET /api/my-rentals` - Get user's rentals
- `POST /api/track-access/:rentalId` - Track book access

### Books:
- `GET /api/books` - List available books
- `GET /api/books/:id` - Book details

## 📱 Frontend Features

### Enhanced UI:
- **15 Theme System** - Light, Dark, Ocean, Forest, Sunset, Purple, Rose, Midnight, Galaxy, Gold, Cyber, Cherry, Sky, Emerald, Lavender
- **Responsive Design** - Works on mobile and desktop
- **Modal System** - Beautiful rental selection popup
- **Real-time Updates** - Dynamic pricing and status updates

### Smart Features:
- **Pending Rental System** - Books persist through registration
- **Access Tracking** - Count how many times you've read a book
- **Expiry Warnings** - Visual alerts for expiring rentals
- **Status Badges** - Active, Expiring Soon, Expired indicators

## 🔒 Security Features

- **JWT Authentication** - Secure token-based auth
- **Password Hashing** - bcryptjs protection
- **Input Validation** - SQL injection prevention
- **User Isolation** - Each user sees only their rentals

## 📈 Analytics & Monitoring

### Built-in Tracking:
- **Total rentals per user**
- **Book access frequency**
- **Revenue calculation**
- **Popular books statistics**
- **User engagement metrics**

### Automated Jobs:
- **Rental expiry** - Runs every minute
- **Cleanup tasks** - Remove old data
- **Usage statistics** - Generate reports

## 🎯 Book Categories

1. **Computer Science** (৳14-20)
   - C Programming, Data Structures, Algorithms
   - Database, Operating Systems, Networking

2. **General Science** (৳10-16)
   - Physics, Chemistry, Biology, Mathematics

3. **Science Fiction** (৳5-9)
   - Bengali sci-fi stories and novels

4. **Extra Educational** (৳6-15)
   - English Grammar, ICT, Programming, AI

## 🚀 Advanced Usage

### For Developers:
```javascript
// Add new book category
INSERT INTO book_categories (name, description) 
VALUES ('History', 'Historical books and biographies');

// Process rental programmatically
CALL ProcessBookRental(user_id, book_id, days, @rental_id, @price, @success, @message);

// Get user statistics
SELECT * FROM user_rental_summary WHERE user_id = 1;
```

### For Admins:
- Monitor active rentals via `active_rentals` view
- Track revenue through `rental_history` table
- Manage users and books through database
- View detailed analytics and usage patterns

## 🌟 Benefits

### For Users:
- ✅ **Affordable pricing** - ৳5-20 range with daily increments
- ✅ **Flexible durations** - Rent for exactly as long as you need
- ✅ **Easy access** - One-click reading from dashboard
- ✅ **Usage tracking** - See your reading habits
- ✅ **Multi-device support** - Access from anywhere

### For Business:
- ✅ **Automated system** - No manual intervention needed
- ✅ **Scalable architecture** - Handle thousands of users
- ✅ **Revenue tracking** - Complete financial overview
- ✅ **User analytics** - Understand customer behavior
- ✅ **Data security** - Protected user information

## 📞 Support

For issues or questions:
1. Check the database connection in XAMPP
2. Verify all dependencies are installed
3. Check server logs for error messages
4. Ensure database schema is properly imported

---

**🎉 Ready to start your digital book rental business!**

*RentRead - Making knowledge accessible, one rental at a time* 📚✨