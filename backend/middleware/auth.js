const jwt = require('jsonwebtoken');
const JWT_SECRET = process.env.JWT_SECRET || '20586ec70b134b4e7c25974abd7cc38d474ed0ecdb517971ba961ced5f18405d';  // Ensure this is set

const authenticateUser = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) {
        return res.status(401).json({ error: 'Acesso negado. Token não fornecido.' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;  // Attach the decoded user data to the request object
        next();
    } catch (error) {
        res.status(401).json({ error: 'Token inválido.' });
    }
};

module.exports = authenticateUser;
