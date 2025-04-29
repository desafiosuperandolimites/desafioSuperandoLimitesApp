const admin = require('firebase-admin');

async function verifyGoogleToken(token) {
    try {
        // Debug
        console.log('token', token);

        // Verify the token using Firebase Admin SDK
        const decodedToken = await admin.auth().verifyIdToken(token);

        // Debug
        console.log('decodedToken', decodedToken);

        return decodedToken; // Contains user info such as email, name, uid, etc.
    } catch (error) {
        throw new Error('Invalid Google token');
    }
}

module.exports = { verifyGoogleToken };
