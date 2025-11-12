const mysql = require('mysql2/promise');
require('dotenv').config();

async function checkBooks() {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || '127.0.0.1',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'rentread'
    });

    console.log('✅ Connected to database\n');

    // Get all books
    const [books] = await connection.query('SELECT id, title, image_url FROM books');
    
    if (books.length === 0) {
      console.log('📚 No books found in database');
    } else {
      console.log(`📚 Found ${books.length} books:\n`);
      books.forEach(book => {
        console.log(`ID: ${book.id}`);
        console.log(`Title: ${book.title}`);
        console.log(`Image URL: ${book.image_url || 'NULL'}`);
        console.log('---');
      });
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

checkBooks();
