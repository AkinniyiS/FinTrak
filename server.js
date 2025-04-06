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

//  REGISTER: Save new users in MySQL
app.post("/api/auth/register", async (req, res) => {
    const { firstName, lastName, email, password, username } = req.body;

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
                "INSERT INTO User (first_name, last_name, username, email, password) VALUES (?, ?, ?, ?, ?)",
                [firstName, lastName, username, email, hashedPassword],
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
// Add New Accounts
app.post("/api/accounts", (req,res)=> {
    const {user_id, account_name, account_type, balance } = req.body;

    if (!user_id || !account_name || !account_type) {
        return res.status(400).json({ error: "Missing required fields" });
    }
    const query ='INSERT INTO Account (user_id, account_name, account_type, balance) VALUES (?,?,?,?)';
    db.query(query, [user_id, account_name, account_type, balance || 0], (err, result)=> {
        if(err){
            console.error("Account insert error:", err);
            return res.status(500).json({ error: "Server error" });
        }

        res.status(201).json({ message: "Account Created", account_id: result.insertId });
    });
});
// Get Accounts by User
app.get("/api/accounts/user/:userId", (req, res)=>{
    const { userId } = req.params;
    const query = 'SELECT * FROM Account WHERE user_id = ?';

    db.query(query, [userId], (err, results) => {
        if(err) {
            console.error("Fetch accounts error:", err);
            return res.status(500).json ({ error: "Server error" });
        }

        res.json(results);
    });
});

//  LOGIN: Authenticate Firebase Token & Retrieve User from MySQL
app.post("/api/auth/login", async (req, res) => {
    const { email, password } = req.body;

    if (!email || !password) {
        return res.status(400).json({ error: "Email and Password are required" });
    }

    try {
        // Fetch user from MySQL by email
        db.query("SELECT * FROM User WHERE email = ?", [email], async (err, results) => {
            if (err) {
                console.error("Database error:", err);
                return res.status(500).json({ error: "Server error" });
            }

            if (results.length === 0) {
                return res.status(400).json({ error: "User not found" });
            }

            // Check if password matches
            const user = results[0];
            const passwordMatch = await bcrypt.compare(password, user.password);

            if (!passwordMatch) {
                return res.status(400).json({ error: "Incorrect password" });
            }

            // Return user details and userId (along with JWT token)
            const authToken = jwt.sign({ id: user.id, email }, SECRET_KEY, { expiresIn: "1h" });

            res.json({
                message: "Login successful",
                token: authToken,
                userId: user.id,
            });
        });
    } catch (error) {
        console.error("Server error:", error);
        res.status(500).json({ error: "Server error" });
    }
});

// Start server
const PORT = 4000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
