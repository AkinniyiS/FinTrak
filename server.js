const express = require("express");
const cors = require("cors");
const db = require("./database"); // MySQL connection
const admin = require("./firebaseConfig"); // Firebase setup
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");

const app = express();
app.use(cors()); // Enable CORS
app.use(express.json());

const SECRET_KEY = "your_secret_key";

// 🔹 REGISTER: Save new users in MySQL
app.post("/api/auth/register", async (req, res) => {
    const { email, password, username } = req.body;

    if (!email || !password || !username) {
        return res.status(400).json({ error: "All fields are required" });
    }

    try {
        db.query("SELECT * FROM User WHERE email = ?", [email], async (err, results) => {
            if (err) {
                console.error("Database error:", err);
                return res.status(500).json({ error: "Server error" });
            }

            if (results.length > 0) {
                return res.status(400).json({ error: "User already exists" });
            }

            const hashedPassword = await bcrypt.hash(password, 10);

            db.query(
                "INSERT INTO User (username, email, password) VALUES (?, ?, ?)",
                [username, email, hashedPassword],
                (err, result) => {
                    if (err) {
                        console.error("Insert error:", err);
                        return res.status(500).json({ error: "Server error" });
                    }

                    res.status(201).json({ message: "User registered successfully" });
                }
            );
        });
    } catch (error) {
        console.error("Server error:", error);
        res.status(500).json({ error: "Server error" });
    }
});

// 🔹 LOGIN: Authenticate Firebase Token & Retrieve User from MySQL
app.post("/api/auth/firebase", async (req, res) => {
    const { token } = req.body;

    if (!token) {
        return res.status(400).json({ error: "Token is required" });
    }

    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        const { email, uid, name } = decodedToken;

        db.query("SELECT * FROM user WHERE email = ?", [email], (err, results) => {
            if (err) {
                console.error("Database error:", err);
                return res.status(500).json({ error: "Database error" });
            }

            if (results.length === 0) {
                db.query("INSERT INTO user (username, email) VALUES (?, ?)", [name || uid, email], (err, result) => {
                    if (err) {
                        console.error("Insert error:", err);
                        return res.status(500).json({ error: "Server error" });
                    }

                    const authToken = jwt.sign({ id: result.insertId, email }, SECRET_KEY, { expiresIn: "1h" });

                    return res.json({ message: "User registered via Firebase", token: authToken });
                });
            } else {
                const authToken = jwt.sign({ id: results[0].id, email }, SECRET_KEY, { expiresIn: "1h" });
                return res.json({ message: "Login successful", token: authToken });
            }
        });
    } catch (error) {
        console.error("Firebase token error:", error);
        res.status(401).json({ error: "Invalid Firebase Token" });
    }
});

// Start server
const PORT = 4000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
