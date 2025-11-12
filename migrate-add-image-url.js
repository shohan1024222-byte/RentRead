const mysql = require('mysql2/promise');
require('dotenv').config();

async function addImageUrlColumn() {
  let connection;
  try {
    // Create connection
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || '127.0.0.1',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'rentread'
    });

    console.log('✅ Connected to database');

    // Check if column exists
    const [columns] = await connection.query(`
      SELECT COLUMN_NAME 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_SCHEMA = ? AND TABLE_NAME = 'books' AND COLUMN_NAME = 'image_url'
    `, [process.env.DB_NAME || 'rentread']);

    if (columns.length > 0) {
      console.log('✅ Column image_url already exists in books table');
    } else {
      // Add the column
      console.log('⏳ Adding image_url column to books table...');
      await connection.query(`
        ALTER TABLE books ADD COLUMN image_url VARCHAR(500) AFTER is_available
      `);
      console.log('✅ Successfully added image_url column to books table');
    }

    // Show table structure
    const [structure] = await connection.query('DESCRIBE books');
    console.log('\n📋 Books table structure:');
    structure.forEach(col => {
      console.log(`  - ${col.Field} (${col.Type})`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.code === 'ECONNREFUSED') {
      console.error('💡 Make sure XAMPP MySQL is running!');
    }
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n✅ Database connection closed');
    }
  }
}

// Run the migration
addImageUrlColumn();
