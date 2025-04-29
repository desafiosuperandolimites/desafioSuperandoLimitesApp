const express = require('express');
const router = express.Router();
const cadastroController = require('../controllers/cadastroController');

router.post('/cadastro/form/admin', cadastroController.adminCadastroForm);	

module.exports = router;