const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db');
const router = express.Router();

const JWT_SECRET = process.env.JWT_SECRET || 'secretkey';

// Admin login
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  console.log('Admin login attempt:', { email, hasPassword: !!password });
  
  if (!email || !password) {
    console.log('Missing email or password');
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    // Check if admin exists
    console.log('Querying admin with email:', email);
    const [rows] = await pool.query('SELECT id, email, password_hash, name, is_active FROM admin_users WHERE email = ?', [email]);
    
    console.log('Query result:', rows.length > 0 ? 'Admin found' : 'Admin not found');
    
    if (!rows || rows.length === 0) {
      console.log('Admin not found with email:', email);
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const admin = rows[0];
    console.log('Found admin:', { id: admin.id, email: admin.email, is_active: admin.is_active });

    // Check if admin is active
    if (!admin.is_active) {
      console.log('Admin account is deactivated');
      return res.status(401).json({ error: 'Admin account is deactivated' });
    }

    // Verify password
    console.log('Verifying password...');
    const validPassword = await bcrypt.compare(password, admin.password_hash);
    console.log('Password valid:', validPassword);
    
    if (!validPassword) {
      console.log('Invalid password for admin:', email);
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Update last login
    console.log('Updating last login for admin:', admin.id);
    await pool.query('UPDATE admin_users SET last_login = CURRENT_TIMESTAMP WHERE id = ?', [admin.id]);

    // Generate JWT token
    const token = jwt.sign(
      { 
        id: admin.id, 
        email: admin.email, 
        name: admin.name,
        role: 'admin' 
      }, 
      JWT_SECRET, 
      { expiresIn: '24h' }
    );

    console.log('Login successful for admin:', admin.email);
    
    res.json({ 
      success: true,
      token,
      admin: {
        id: admin.id,
        email: admin.email,
        name: admin.name
      }
    });

  } catch (error) {
    console.error('Admin login error:', error);
    res.status(500).json({ error: 'Login failed' });
  }
});

// Admin token verification
router.get('/verify', async (req, res) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = jwt.verify(token, JWT_SECRET);
    
    // Check if it's an admin token
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Admin access required' });
    }

    // Verify admin still exists and is active
    const [rows] = await pool.query('SELECT id, email, name, is_active FROM admin_users WHERE id = ?', [decoded.id]);
    
    if (!rows || rows.length === 0 || !rows[0].is_active) {
      return res.status(401).json({ error: 'Invalid admin token' });
    }

    const admin = rows[0];
    
    res.json({ 
      valid: true, 
      admin: {
        id: admin.id,
        email: admin.email,
        name: admin.name
      }
    });

  } catch (error) {
    console.error('Admin token verification error:', error);
    res.status(401).json({ error: 'Invalid token' });
  }
});

module.exports = router;