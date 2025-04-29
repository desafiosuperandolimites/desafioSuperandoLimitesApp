// routes/opcoesCampoRoutes.js

const express = require('express');
const router = express.Router();
const opcoesCampoController = require('../controllers/opcoesCampoController');

router.post('/opcoesCampo', opcoesCampoController.adicionarOpcao);
router.put('/opcoesCampo/:id', opcoesCampoController.editarOpcao);
router.delete('/opcoesCampo/:id', opcoesCampoController.removerOpcao);
router.get('/opcoesCampo', opcoesCampoController.listarOpcoes);
router.get('/opcoesCampo/:id', opcoesCampoController.visualizarOpcao);

module.exports = router;
