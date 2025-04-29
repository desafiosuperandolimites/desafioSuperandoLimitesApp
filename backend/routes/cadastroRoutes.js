const express = require('express');
const router = express.Router();
const cadastroController = require('../controllers/cadastroController');

// Form-based registration
router.post('/cadastro/form', cadastroController.cadastroForm);
router.post('/cadastro/verificar-email', cadastroController.verificarEmailExistente);

module.exports = router;