const jwt = require('jsonwebtoken');
const Usuario = require('../models/usuarioModel');
const { verifyGoogleToken } = require('../google_auth');

// Secret key for JWT
const JWT_SECRET = '20586ec70b134b4e7c25974abd7cc38d474ed0ecdb517971ba961ced5f18405d'; // Replace in production
const SESSION_EXPIRATION = '5h'; // 5 hours

exports.googleSignIn = async (req, res) => {
    const { token } = req.body;

    try {
        // Debug
        console.log('token', token);

        // Verify the token with Firebase Admin SDK
        const firebaseUser = await verifyGoogleToken(token);

        // Debug
        console.log('firebaseUser', firebaseUser);

        // Check if user already exists in the database
        let user = await Usuario.findOne({ where: { EMAIL: firebaseUser.email } });

        // Debug
        console.log('user', user);

        if (!user) {
            // If not, create a new user
            user = await Usuario.create({
                EMAIL: firebaseUser.email,
                NOME: firebaseUser.name || firebaseUser.email.split('@')[0], // Fallback to email if name not available
                ID_PERFIL_TIPO: 3,
                ID_GRUPO_EVENTO: 1,
            });
        }

        // Generate JWT token
        const jwtToken = jwt.sign(
            { ID: user.ID, ID_PERFIL_TIPO: user.ID_PERFIL_TIPO },
            JWT_SECRET,
            { expiresIn: SESSION_EXPIRATION }
        );

        res.json({ token: jwtToken, user });
    } catch (error) {
        console.error('Google Sign-In Error:', error);
        res.status(401).json({ message: 'Invalid Google Sign-In' });
    }
};
