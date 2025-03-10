CREATE TABLE User (
    userid INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    register DATETIME DEFAULT CURRENT_TIMESTAMP,
    login DATETIME,
    logout DATETIME
);



CREATE TABLE Report (
    reportID INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    startDate DATETIME,
    endDate DATETIME,
    generateReport DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (userid) REFERENCES User(userid)
);


CREATE TABLE Transaction (
    transactionID INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    amount DECIMAL(10, 2) NOT NULL,
    category VARCHAR(255),
    date DATETIME DEFAULT CURRENT_TIMESTAMP,
    addtransaction DATETIME DEFAULT CURRENT_TIMESTAMP,
    edittransaction DATETIME,
    deletetransaction DATETIME,
    FOREIGN KEY (userid) REFERENCES User(userid)
);


CREATE TABLE Budget (
    budgetID INT AUTO_INCREMENT PRIMARY KEY,
    userid INT,
    category VARCHAR(255),
    amount DECIMAL(10, 2) NOT NULL,
    setbudget DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatebudget DATETIME,
    checkbudget BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (userid) REFERENCES User(userid)
);

