const mysql = require('mysql2/promise');
require('dotenv').config();

// Dashboard books with image URLs
const dashboardBooks = {
  "C Programming (Bangla)": "/img/covers/c_programming.gif",
  "Data Structure (Bangla)": "/img/covers/data_structure.jpg",
  "Algorithm in Bangla": "/img/covers/algorithm.gif",
  "Database Management": "/img/covers/database_management.jpg",
  "Operating System": "/img/covers/operating_system.jpg",
  "Computer Networking": "/img/covers/computer_networking.gif",
  "Physics for Everyone": "/img/covers/physics.png",
  "Basic Chemistry": "/img/covers/basic_chemistry.webp",
  "Biology (Bangla Edition)": "/img/covers/biology.jpg",
  "Higher Math": "/img/covers/higher_math.jpg",
  "সহকারী রোবট": "/img/covers/robot.webp",
  "কালো গহ্বরের গল্প": "/img/covers/black_hole.jpg",
  "সহজ বিজ্ঞান কল্পকাহিনী": "/img/covers/easy_scifi.jpg",
  "বিজ্ঞান কল্পকাহিনী সমগ্র": "/img/covers/scifi_collection.jpg",
  "English Grammar": "/img/covers/english_grammar.jpeg",
  "ICT for Beginners": "/img/covers/ict.jpg",
  "Learn Programming": "/img/covers/learn_programming.jpg",
  "Artificial Intelligence Basics": "/img/covers/ai.jpg"
};

async function updateBookImages() {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || '127.0.0.1',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'rentread'
    });

    console.log('✅ Connected to database\n');

    let updated = 0;
    for (const [title, imageUrl] of Object.entries(dashboardBooks)) {
      const [result] = await connection.query(
        'UPDATE books SET image_url = ? WHERE title = ?',
        [imageUrl, title]
      );
      
      if (result.affectedRows > 0) {
        console.log(`✅ Updated: ${title}`);
        updated++;
      }
    }

    console.log(`\n📊 Total books updated: ${updated}`);

    // Show updated books
    const [books] = await connection.query('SELECT id, title, image_url FROM books WHERE image_url IS NOT NULL LIMIT 5');
    console.log('\n📚 Sample updated books:');
    books.forEach(book => {
      console.log(`  ${book.title}: ${book.image_url}`);
    });

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    if (connection) {
      await connection.end();
      console.log('\n✅ Done!');
    }
  }
}

updateBookImages();
