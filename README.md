# fintrak

#  Financial Tracker App

A mobile-first financial management app built with Flutter and Express.js, designed to help users track income, expenses, and view spending reports with intuitive charts.

---

##  Features

-  User authentication
-  Add and manage multiple accounts
-  Log income and expenses with category & description
-  Generate reports with pie charts by date range
-  View balances and transaction history per account

---

## Built With
- **Frontend:** Flutter (Dart)
- **Backend:** Express.js (Node.js)
- **Database:** MySQL
- **Authentication:** Firebase (for auth), bcrypt (for password hashing)

---


##  Getting Started

### Prerequisites

- Flutter SDK
- Node.js & npm
- MySQL server
- Firebase project (for authentication)

### Installation
npm install
#### Clone the repo
```bash
git clone https://github.com/AkinniyiS/fintrak.git
cd fintrak

#### dependencies
fl_chart: ^0.70.2 #for pie chart
  intl: ^0.20.2
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  http: ^1.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  http: ^1.2.1 # for network requests
  mockito: ^5.4.4 # for mocking
  build_runner: ^2.4.9

#### Backend
  "dependencies": {
    "bcrypt": "^5.1.1",
    "cors": "^2.8.5",
    "express": "^4.21.2",
    "firebase-admin": "^13.2.0",
    "jsonwebtoken": "^9.0.2",
    "mysql2": "^3.13.0"