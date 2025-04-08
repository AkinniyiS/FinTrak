const mysql = require('mysql2/promise');

// Set up MySQL connection
const db = mysql.createPool({
    connectionLimit: 20,
    host: 'fintrakdb.cfm2aqwg6699.us-east-2.rds.amazonaws.com',
    user: 'fintrakdbadmin',         
    password: 'FinTrak_223', 
    database: 'fintrak_db',          
});



module.exports = db;
