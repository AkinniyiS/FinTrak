const mysql = require('mysql2');

// Set up MySQL connection
const db = mysql.createConnection({
    connectionLimit: 10,
    host: 'fintrak-db.cfm2aqwg6699.us-east-2.rds.amazonaws.com',
    user: 'ftdbadmin',         
    password: 'FinTrak_223', 
    database: 'fintrak_db',          
});

// Attempt to connect to the MySQL database
db.connect((err) => {
    if (err) {
        console.error('Error connecting to the database:', err.message);
        return; // Stop execution if the connection fails
    }
    console.log('Successfully connected to the database.');
});

module.exports = db;
