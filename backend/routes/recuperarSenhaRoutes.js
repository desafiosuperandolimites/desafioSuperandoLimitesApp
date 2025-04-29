const express = require('express');
const path = require('path');
const router = express.Router();
const recuperarSenhaController = require('../controllers/recuperarSenhaController');

router.post('/recuperar-senha', recuperarSenhaController.emailRecuperarSenha);
router.get('/recuperar-senha/styles.css', (req, res) => {
    res.sendFile(path.join(__dirname, '../html/styles.css'));
});
router.get('/recuperar-senha/logo.png', (req, res) => {
    res.sendFile(path.join(__dirname, '../html/logo.png'));
});
router.get('/recuperar-senha/:token', (req, res) => {
    res.sendFile(path.join(__dirname, '../html/recuperar_senha.html')); // Adjust the path to your HTML file
});
router.post('/recuperar-senha/:token', recuperarSenhaController.resetarSenha);

module.exports = router;
