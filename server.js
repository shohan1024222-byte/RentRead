require('dotenv').config();
const express = require('express');
const path = require('path');
const cors = require('cors');
const cron = require('node-cron');
const jwt = require('jsonwebtoken');
const multer = require('multer');
const fs = require('fs');

const app = express();
app.use(cors());
app.use(express.json());

// static frontend
app.use(express.static(path.join(__dirname, 'public')));

// Ensure img/covers directory exists
const uploadsDir = path.join(__dirname, 'public', 'img', 'covers');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    // Generate unique filename with timestamp
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, file.fieldname + '-' + uniqueSuffix + ext);
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 5 * 1024 * 1024 // 5MB limit
  },
  fileFilter: function (req, file, cb) {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// Configure multer for book file uploads (PDF, PPTX)
const booksStorageDir = path.join(__dirname, 'storage', 'books');
if (!fs.existsSync(booksStorageDir)) {
  fs.mkdirSync(booksStorageDir, { recursive: true });
}

const bookStorage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, booksStorageDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const ext = path.extname(file.originalname);
    cb(null, 'book-' + uniqueSuffix + ext);
  }
});

const bookUpload = multer({
  storage: bookStorage,
  limits: {
    fileSize: 50 * 1024 * 1024 // 50MB limit for books
  },
  fileFilter: function (req, file, cb) {
    const allowedTypes = [
      'application/pdf',
      'application/vnd.ms-powerpoint',
      'application/vnd.openxmlformats-officedocument.presentationml.presentation'
    ];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Only PDF and PPTX files are allowed!'), false);
    }
  }
});

// Try to connect to database, but don't crash if it fails
let db = null;
try {
  db = require('./db');
  console.log('Database connection initialized');
} catch (error) {
  console.warn('Database connection failed, running without database:', error.message);
}

// Include routes only if database is available
if (db) {
  try {
    const authRoutes = require('./routes/auth');
    const booksRoutes = require('./routes/books');
    const rentRoutes = require('./routes/rent');
    const adminRoutes = require('./routes/admin');
    
    app.use('/api/auth', authRoutes);
    app.use('/api/books', booksRoutes);
    app.use('/api/rent', rentRoutes);
    app.use('/api/admin', adminRoutes);
    console.log('API routes loaded successfully');
  } catch (error) {
    console.warn('Failed to load some routes:', error.message);
  }
}

// Middleware to verify JWT token
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Access token required' });
  }

  jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key', (err, user) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Image upload endpoint
app.post('/api/upload', upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file uploaded' });
    }

    // Return just the filename (will be prefixed with /img/covers/ in frontend)
    const filename = req.file.filename;
    
    res.json({ 
      success: true, 
      filename: filename,
      path: `/img/covers/${filename}`,
      message: 'File uploaded successfully' 
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ success: false, error: 'Upload failed: ' + error.message });
  }
});

// Book file upload endpoint (PDF, PPTX)
app.post('/api/upload-book', bookUpload.single('bookfile'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file uploaded' });
    }

    const filename = req.file.filename;
    const fileSizeMB = (req.file.size / (1024 * 1024)).toFixed(2);
    
    res.json({ 
      success: true, 
      filename: filename,
      path: `/storage/books/${filename}`,
      size: fileSizeMB + ' MB',
      message: 'Book file uploaded successfully' 
    });
  } catch (error) {
    console.error('Book upload error:', error);
    res.status(500).json({ success: false, error: 'Book upload failed: ' + error.message });
  }
});

// Serve book files from storage/books directory
app.use('/storage/books', express.static(path.join(__dirname, 'storage', 'books')));

// Basic rental API endpoints (with database if available)
if (db) {
  // Basic endpoints are handled by routes - no need for duplicates here
} else {
  // Fallback APIs when database is not available
  app.post('/api/rent-book', (req, res) => {
    res.json({ success: false, message: 'Database not available. Please set up MySQL in XAMPP first.' });
  });
  
  app.get('/api/my-rentals', (req, res) => {
    res.json({ success: true, rentals: [], message: 'Database not available' });
  });
  
  app.post('/api/track-access/:rentalId', (req, res) => {
    res.json({ success: false, message: 'Database not available' });
  });

  // Lightweight in-memory books API so frontend and admin can function when DB is not present
  let _memoryBooks = [
    { id: 1, title: 'C Programming (Bangla)', description: 'Bangla edition', filename: '', author: 'Unknown', price_per_day: 10, category: 'Computer Science', total_pages: 200, is_available: 1, image_url: '/img/c_programming_ba.svg' },
    { id: 2, title: 'Data Structure (Bangla)', description: 'Data structures', filename: '', author: 'Unknown', price_per_day: 12, category: 'Computer Science', total_pages: 250, is_available: 1, image_url: '/img/data_structure_ba.svg' }
  ];

  app.get('/api/books', (req, res) => {
    const q = req.query.q;
    let list = _memoryBooks.slice().reverse();
    if (q) {
      const term = q.toLowerCase();
      list = list.filter(b => (b.title||'').toLowerCase().includes(term) || (b.category||'').toLowerCase().includes(term) || (b.author||'').toLowerCase().includes(term));
    }
    res.json({ success: true, books: list });
  });

  app.post('/api/books', (req, res) => {
    const body = req.body || {};
    const id = (_memoryBooks.reduce((m,b)=>Math.max(m,b.id), 0) || 0) + 1;
    const book = { id, title: body.title||'Untitled', description: body.description||'', filename: body.filename||'', author: body.author||'', price_per_day: body.price_per_day||0, category: body.category||'', total_pages: body.total_pages||0, is_available: body.is_available?1:0, image_url: body.image_url||null };
    _memoryBooks.push(book);
    res.json({ success: true, book });
  });

  app.put('/api/books/:id', (req, res) => {
    const id = parseInt(req.params.id,10);
    const idx = _memoryBooks.findIndex(b=>b.id===id);
    if (idx === -1) return res.status(404).json({ success: false, error: 'Not found' });
    const body = req.body || {};
    _memoryBooks[idx] = { ..._memoryBooks[idx], ...body, id };
    res.json({ success: true, book: _memoryBooks[idx] });
  });

  app.delete('/api/books/:id', (req, res) => {
    const id = parseInt(req.params.id,10);
    const idx = _memoryBooks.findIndex(b=>b.id===id);
    if (idx === -1) return res.status(404).json({ success: false, error: 'Not found' });
    _memoryBooks.splice(idx,1);
    res.json({ success: true, deletedId: id });
  });
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    database: db ? 'Connected' : 'Not Available',
    message: 'RentRead server is running'
  });
});

// Catch all route for frontend
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// background job: expire rentals every minute (only if database available)
if (db) {
  try {
    const { expireOldRentals } = require('./utils/cleanup');
    cron.schedule('* * * * *', async () => {
      try {
        await expireOldRentals();
        console.log('Expired rentals run completed');
      } catch (err) {
        console.error('Error expiring rentals', err);
      }
    });
    console.log('Background job scheduled');
  } catch (error) {
    console.warn('Failed to set up background job:', error.message);
  }
}

const PORT = process.env.PORT || 4000;

// Start server with error handling
const server = app.listen(PORT, () => {
  console.log(`🚀 RentRead server running on port ${PORT}`);
  console.log(`📚 Visit: http://localhost:${PORT}`);
  console.log(`🔍 Health check: http://localhost:${PORT}/health`);
  if (!db) {
    console.log('⚠️  Database not connected - some features may be limited');
    console.log('💡 Start XAMPP MySQL and create database to enable full functionality');
  }
});

// Handle server errors
server.on('error', (error) => {
  if (error.code === 'EADDRINUSE') {
    console.error(`❌ Port ${PORT} is already in use`);
    console.log('💡 Try stopping other servers or use a different port');
    process.exit(1);
  } else {
    console.error('❌ Server error:', error);
  }
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\n🛑 Shutting down server gracefully...');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});
