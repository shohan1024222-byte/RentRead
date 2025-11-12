# RentRead Admin Access Instructions

## 🔒 Admin Panel Security

The admin panel is **completely isolated** from user authentication for security.

### 📍 How to Access Admin Panel

1. **ONLY from Index Page**: Go to `http://localhost:5000` (Home page)
2. **Click "Admin"** in the navigation menu
3. **Admin Login Required**: You'll see the admin login dialog

### 🔑 Admin Credentials

- **Email**: `admin@gmail.com`
- **Password**: `123`

### 🚫 Access Restrictions

- ❌ **Dashboard**: No admin link (user area only)
- ❌ **My Rentals**: No admin link (user area only)
- ❌ **User Login**: Cannot access admin from user accounts
- ✅ **Index Page**: Only way to access admin panel

### 🛡️ Security Features

1. **Separate Authentication**: Admin login is completely separate from user login
2. **Isolated Storage**: Admin tokens stored separately (`adminToken` vs user `token`)
3. **No Cross-Access**: Users cannot access admin even when logged in
4. **Admin-Only Navigation**: Admin links removed from all user pages

### 💾 Database

Admin credentials are stored in the `admin_users` table, completely separate from the `users` table.

### 🔄 Logout

When you logout from admin panel, only admin session ends. User sessions remain unaffected.

---

**For Development**: If you need to reset admin credentials, run `node setup-admin.js`