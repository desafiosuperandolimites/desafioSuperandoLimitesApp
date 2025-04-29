const express = require('express');
const router = express.Router();
const dadosBancariosAdmController = require('../controllers/dadosBancariosAdmController');

// Routes for user management
router.post('/dadosBancariosAdm', dadosBancariosAdmController.criarDadosBancariosAdm);
router.put('/dadosBancariosAdm/:id', dadosBancariosAdmController.atualizarDadosBancariosAdm);
router.get('/dadosBancariosAdm/:id', dadosBancariosAdmController.visualizarDadosBancariosAdm);
router.delete('/dadosBancariosAdm/:id', dadosBancariosAdmController.deletarDadosBancariosAdm);

module.exports = router;
