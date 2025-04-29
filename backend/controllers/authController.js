const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const Usuario = require('../models/usuarioModel');

// Secret key for JWT
const JWT_SECRET = '20586ec70b134b4e7c25974abd7cc38d474ed0ecdb517971ba961ced5f18405d';  // Replace with a secure key in production

// Session expiration time
const SESSION_EXPIRATION = '5h';  // 5 horas

// Realizar login (authenticate user)
exports.realizarLogin = async (req, res) => {
    try {
        const { EMAIL, SENHA } = req.body;

        // Validate the input
        if (!EMAIL || !SENHA) {
            return res.status(400).json({ error: 'Email e senha são obrigatórios.' });
        }

        // Find the user by email
        
        const usuario = await Usuario.findOne({ where: { EMAIL } });

        if (!usuario) {
            return res.status(400).json({ error: 'Email não encontrado.' });
        }

        if (!usuario.SITUACAO) {
            return res.status(400).json({ error: 'Sua conta está desativada, entre em contato com um administrador pelo contato (63) 99207-2064 para ativar novamente sua conta.' });
        }
        
        // Check if the user's password is null (indicating a Google or Apple sign-in)
        if (!usuario.SENHA) {
            return res.status(400).json({ error: 'Este email foi cadastrado utilizando o método de login Google ou Apple, tente através deles.' });
        }
        

        // Compare the provided password with the stored hash
        const isPasswordValid = await bcrypt.compare(SENHA, usuario.SENHA);
        if (!isPasswordValid) {
            return res.status(400).json({ error: 'Senha incorreta.' });
        }

        // Generate JWT token
        const token = jwt.sign(
            { ID: usuario.ID, ID_PERFIL_TIPO: usuario.ID_PERFIL_TIPO },
            JWT_SECRET,
            // { expiresIn: SESSION_EXPIRATION }
        );

        // Send the token as a response
        res.json({ token, message: 'Login realizado com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Realizar logout (invalidate session)
exports.realizarLogout = (req, res) => {
    // In a typical JWT setup, there's no need to "invalidate" a token server-side.
    // You can simply inform the client to delete the token.
    // Alternatively, you can manage a token blacklist if needed.

    res.json({ message: 'Logout realizado com sucesso.' });
};

exports.updateFcmToken = async (req, res) => {
    const { userId, fcmToken } = req.body;

    if (!userId || !fcmToken) {
        return res.status(400).json({ error: 'ID de usuário e token FCM são necessários' });
    }

    try {
        const usuario = await Usuario.findByPk(userId);
        if (!usuario) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        usuario.FCM_TOKEN = fcmToken;
        await usuario.save();

        res.status(200).json({ message: 'Token FCM atualizado com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}
