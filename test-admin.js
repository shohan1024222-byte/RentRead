const bcrypt = require('bcryptjs');
const mysql = require('mysql2/promise');

async function testAdminLogin() {
    console.log('🔍 Testing admin login...');
    
    try {
        // Connect to database
        const connection = await mysql.createConnection({
            host: 'localhost',
            user: 'root',
            password: '',
            database: 'rentread'
        });
        
        console.log('✅ Database connection successful');
        
        // Get admin user
        const [rows] = await connection.execute(
            'SELECT id, email, password_hash, name, is_active FROM admin_users WHERE email = ?',
            ['admin@gmail.com']
        );
        
        if (rows.length === 0) {
            console.log('❌ Admin user not found');
            return;
        }
        
        const admin = rows[0];
        console.log('✅ Admin user found:', {
            id: admin.id,
            email: admin.email,
            name: admin.name,
            is_active: admin.is_active
        });
        
        // Test password
        const testPassword = '123';
        const isPasswordValid = await bcrypt.compare(testPassword, admin.password_hash);
        
        console.log('🔑 Password test result:', isPasswordValid ? '✅ Valid' : '❌ Invalid');
        console.log('🔐 Stored hash:', admin.password_hash);
        
        // Test with different passwords
        const testPasswords = ['123', 'admin', 'password'];
        console.log('\n🧪 Testing different passwords:');
        
        for (const pwd of testPasswords) {
            const isValid = await bcrypt.compare(pwd, admin.password_hash);
            console.log(`  "${pwd}": ${isValid ? '✅' : '❌'}`);
        }
        
        await connection.end();
        
    } catch (error) {
        console.error('❌ Error:', error);
    }
}

testAdminLogin();