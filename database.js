const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'SamuelAkin',         
    password: 'Imperfection@123', 
    database: 'fintrak'
});

db.connect(err => {
    if (err) {
        console.error('Database connection failed:', err);
    } else {
        console.log('Connected to MySQL');
    }
});

module.exports = db;
