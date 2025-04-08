const express = require("express");
const cors = require("cors");
const db = require("./database"); // MySQL connection
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");

const app = express();
app.use(cors());
app.use(express.json());

const SECRET_KEY = "your_secret_key";

// REGISTER: Save new users in MySQL
app.post("/api/auth/register", async (req, res) => {
  const { firstName, lastName, email, password, username } = req.body;

  if (!email || !password || !username) {
    return res.status(400).json({ error: "All fields are required" });
  }

  try {
    // Using async/await for database query
    const [results] = await db.query("SELECT * FROM User WHERE email = ?", [email]);

    if (results.length > 0) {
      return res.status(400).json({ error: "User already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    // Using async/await for database query
    await db.query( 
      "INSERT INTO User (first_name, last_name, username, email, password) VALUES (?, ?, ?, ?, ?)",
      [firstName, lastName, username, email, hashedPassword]
    );

    res.status(201).json({ message: "User registered successfully" });
  } catch (error) {
    console.error("Server error:", error);
    res.status(500).json({ error: "Server error" });
  }
});

//Get User ID by Email (after Firebase login)
app.post("/api/auth/get-sql-user", async (req, res) => {
  const { email } = req.body;

  if (!email) return res.status(400).json({ error: "Email is required" });

  try {
    // Using async/await for database query
    const [results] = await db.query("SELECT id FROM User WHERE email = ?", [email]); 

    if (results.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({ userId: results[0].id });
  } catch (err) {
    return res.status(500).json({ error: "Server error" });
  }
});

// Add New Account
app.post("/api/accounts", async (req, res) => {
  const { user_id, account_name, account_type, balance } = req.body;

  if (!user_id || !account_name || !account_type) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  const query = "INSERT INTO Account (user_id, account_name, account_type, balance) VALUES (?,?,?,?)";
  
  try {
    //  Using async/await for database query
    const [result] = await db.query(query, [user_id, account_name, account_type, balance || 0]); 

    res.status(201).json({ message: "Account Created", account_id: result.insertId });
  } catch (err) {
    return res.status(500).json({ error: "Server error" });
  }
});

// Get Accounts by User
app.get("/api/accounts/user/:userId", async (req, res) => {
  const { userId } = req.params;

  const query = "SELECT * FROM Account WHERE user_id = ?";
  try {
    // Using async/await for database query
    const [results] = await db.query(query, [userId]); 

    res.json(results);
  } catch (err) {
    return res.status(500).json({ error: "Server error" });
  }
});

// Add Transaction
app.post("/api/transactions/add", async (req, res) => {
  const { amount } = req.body;

  if (!amount) {
    return res.status(400).json({ error: "Cost is required" });
  }

  try {
    //  Using async/await for database query
    await db.query("INSERT INTO Transaction (amount) VALUES (?)", [amount]); 

    res.status(201).json({ message: "Transaction added successfully" });
  } catch (err) {
    console.error("Insert error:", err);
    return res.status(500).json({ error: "Server error" });
  }
});

// Fetch user's account balance from SQL
app.get('/api/user/:id/balance', async (req, res) => {
  const userId = req.params.id;

  try {
    // Using async/await for database query
    const [rows] = await db.query( 
      'SELECT balance FROM Account WHERE user_id = ?',
      [userId]
    ); 
    
    if (rows.length > 0) {
      // Grab balance from the query
      let balance = rows[0].balance;

      // If balance is null, set it to 0.00
      if (balance === null) {
        balance = 0.00;
      }

      // Ensure it's a float before sending
      balance = parseFloat(balance);
      
      res.json({ balance });
    } else {
      res.status(404).json({ error: 'Account not found' });
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Server error' });
  }
});

/// Start server
const PORT = 4000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
