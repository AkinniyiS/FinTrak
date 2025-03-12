const express = require('express');
const db = require('./database'); // MySQL connection
const admin = require('./firebaseConfig'); // Firebase setup
const jwt = require('jsonwebtoken');

const app = express();
app.use(express.json());

const SECRET_KEY = 'your_secret_key';

// Authenticate Firebase Token & Store User in MySQL
app.post('/api/auth/firebase', async (req, res) => {
    const { token } = req.body;

    try {
        // Verify Firebase token
        const decodedToken = await admin.auth().verifyIdToken(token);
        const { email, uid, name } = decodedToken;

        // Check if user exists in MySQL
        db.query('SELECT * FROM User WHERE email = ?', [email], (err, results) => {
            if (err) return res.status(500).json({ error: err.message });

            if (results.length === 0) {
                // Register new user in MySQL
                db.query('INSERT INTO User (username, email) VALUES (?, ?)', [name || uid, email], (err, result) => {
                    if (err) return res.status(500).json({ error: err.message });

                    // Generate JWT Token
                    const authToken = jwt.sign({ id: result.insertId, email }, SECRET_KEY, { expiresIn: '1h' });

                    res.json({ message: 'User registered', token: authToken });
                });
            } else {
                // User exists, return token
                const authToken = jwt.sign({ id: results[0].id, email }, SECRET_KEY, { expiresIn: '1h' });
                res.json({ message: 'Login successful', token: authToken });
            }
        });
    } catch (error) {
        res.status(401).json({ error: 'Invalid Firebase Token' });
    }
});

// Start server
app.listen(4000, () => console.log('Server running on port 3000'));
