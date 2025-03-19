const mysql = require('mysql2');

// Set up MySQL connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'SamuelAkin',         
    password: 'Imperfection@123', 
    database: 'fintrak_db',          
});

// Attempt to connect to the MySQL database
db.connect((err) => {
    if (err) {
        console.error('Error connecting to the database:', err.message);
        return; // Stop execution if the connection fails
    }
    console.log('Successfully connected to MySQL');
});

module.exports = db;
