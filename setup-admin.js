const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

async function setupAdmin() {
    console.log('Setting up admin user...');
    
    // Generate password hash for "123"
    const password = '123';
    const saltRounds = 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);
    
    console.log('Password hash generated:', hashedPassword);
    
    try {
        // Create database connection
        const connection = await mysql.createConnection({
            host: 'localhost',
            user: 'root',
            password: '', // Default XAMPP MySQL password is empty
            database: 'rentread'
        });
        
        console.log('Connected to database');
        
        // Create admin_users table
        const createTableSQL = `
            CREATE TABLE IF NOT EXISTS admin_users (
                id INT AUTO_INCREMENT PRIMARY KEY,
                email VARCHAR(255) NOT NULL UNIQUE,
                password_hash VARCHAR(255) NOT NULL,
                name VARCHAR(255) DEFAULT 'Admin',
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                last_login TIMESTAMP NULL,
                is_active TINYINT(1) DEFAULT 1,
                INDEX idx_email (email)
            ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        `;
        
        await connection.execute(createTableSQL);
        console.log('Admin table created successfully');
        
        // Insert admin user
        const insertAdminSQL = `
            INSERT INTO admin_users (email, password_hash, name) VALUES (?, ?, ?)
            ON DUPLICATE KEY UPDATE 
            password_hash = VALUES(password_hash),
            name = VALUES(name)
        `;
        
        await connection.execute(insertAdminSQL, [
            'admin@gmail.com',
            hashedPassword,
            'Administrator'
        ]);
        
        console.log('Admin user created/updated successfully');
        
        // Verify the admin user
        const [rows] = await connection.execute(
            'SELECT id, email, name, created_at, is_active FROM admin_users WHERE email = ?',
            ['admin@gmail.com']
        );
        
        console.log('Admin user details:', rows[0]);
        
        await connection.end();
        console.log('✅ Admin setup completed successfully!');
        console.log('📧 Email: admin@gmail.com');
        console.log('🔑 Password: 123');
        
    } catch (error) {
        console.error('❌ Error setting up admin:', error);
        
        if (error.code === 'ER_ACCESS_DENIED_ERROR') {
            console.log('💡 Try changing MySQL password in the script or check XAMPP MySQL settings');
        } else if (error.code === 'ECONNREFUSED') {
            console.log('💡 Make sure XAMPP MySQL is running');
        } else if (error.code === 'ER_BAD_DB_ERROR') {
            console.log('💡 Create the "rentread" database first in phpMyAdmin');
        }
    }
}

setupAdmin();