const admin = require("firebase-admin");

// Load the Firebase credentials
const serviceAccount = require(require("path").resolve(__dirname, "firebase-key.json"));

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
