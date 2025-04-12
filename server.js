const express = require("express");
const cors = require("cors");
const db = require("./database"); // MySQL connection
const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");

const headers = {
  'X-Firebase-Locale': 'en',  // Use a valid locale code like 'en' or 'es'
};

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
  console.log("Email received:", email); // 🧪

  if (!email) return res.status(400).json({ error: "Email is required" });

  try {
    const [results] = await db.query("SELECT id FROM User WHERE email = ?", [email]);

    console.log("DB results:", results); // 🧪

    if (results.length === 0) {
      return res.status(404).json({ error: "User not found" });
    }

    res.json({ userId: results[0].id });
  } catch (err) {
    console.error("Server error:", err); // 🧪
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

  const query = "SELECT account_id, account_name, account_type FROM Account WHERE user_id = ?"; // Select specific columns
  try {
    const [results] = await db.query(query, [userId]); 

    res.json(results);
  } catch (err) {
    return res.status(500).json({ error: "Server error" });
  }
});

// /api/transactions/add route to adjust account balance
app.post("/api/transactions/add", async (req, res) => {
  const { amount, account_id, type, category, description } = req.body;

  if (!amount || !account_id || !type || !category) {
    return res.status(400).json({ error: "Missing required fields" });
  }

  const parsedAmount = parseFloat(amount);
  if (isNaN(parsedAmount)) {
    return res.status(400).json({ error: "Invalid amount" });
  }

  const connection = await db.getConnection();
  try {
    await connection.beginTransaction();

    // Insert the transaction
    await connection.query(
      "INSERT INTO Transaction (amount, account_id, type, category, description) VALUES (?, ?, ?, ?, ?)",
      [parsedAmount, account_id, type, category, description || ""]
    );

    // Get current balance
    const [rows] = await connection.query(
      "SELECT balance FROM Account WHERE account_id = ?",
      [account_id]
    );

    if (rows.length === 0) {
      await connection.rollback();
      return res.status(404).json({ error: "Account not found" });
    }

    const currentBalance = parseFloat(rows[0].balance);
    const newBalance = type === "Income"
      ? currentBalance + parsedAmount
      : currentBalance - parsedAmount;

    // Update the account's balance
    await connection.query(
      "UPDATE Account SET balance = ? WHERE account_id = ?",
      [newBalance, account_id]
    );

    await connection.commit();
    res.status(201).json({ message: "Transaction added and balance updated", newBalance });
  } catch (err) {
    await connection.rollback();
    console.error("Transaction error:", err);
    res.status(500).json({ error: "Server error" });
  } finally {
    connection.release();
  }
});

// Fetch user's account balance from SQL
app.get('/api/accounts/:accountId/balance', async (req, res) => {
  const accountId = req.params.accountId;

  try {
    const [rows] = await db.query(
      'SELECT balance FROM Account WHERE account_id = ?',
      [accountId]
    );

    if (rows.length > 0) {
      let balance = rows[0].balance ?? 0.00;
      res.json({ balance: parseFloat(balance) });
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
