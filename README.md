# RentRead

RentRead is a minimal demo project that lets users rent PDF books for a limited time. It uses:

- Frontend: plain HTML + Tailwind CSS (CDN)
- Backend: Node.js with Express
- Database: MySQL (use XAMPP to run MySQL)
- Storage: local folder `storage/books`

Quick start
1. Install Node dependencies:

   npm install

2. Copy `.env.example` to `.env` and update DB credentials (XAMPP MySQL). Default DB user is `root` with no password on most XAMPP installs.

3. Create the database and tables. From your MySQL client (phpMyAdmin or CLI), run `sql/schema.sql`.

4. Place PDF files into `storage/books/` and ensure filenames match `sql/schema.sql` sample rows (e.g. `sample1.pdf`).

5. Start the server:

   npm start

6. Open http://localhost:4000 in your browser.

Notes
- This demo simulates payment by allowing the user to choose rental days. For real payments integrate a payment gateway.
- Background job runs every minute to expire rentals. Adjust `server.js` schedule as needed.
