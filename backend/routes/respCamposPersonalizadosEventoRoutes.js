// routes/respCamposPersonalizadosEventoRoutes.js

const express = require('express');
const router = express.Router();
const respCamposPersonalizadosEventoController = require('../controllers/respCamposPersonalizadosEventoController');

router.post('/respostasCamposPersonalizados', respCamposPersonalizadosEventoController.adicionarRespostaCampoPersonalizado);
router.put('/respostasCamposPersonalizados/:id', respCamposPersonalizadosEventoController.editarRespostaCampoPersonalizado);
router.delete('/respostasCamposPersonalizados/:id', respCamposPersonalizadosEventoController.removerRespostaCampoPersonalizado);
router.get('/respostasCamposPersonalizados', respCamposPersonalizadosEventoController.listarRespostasCamposPersonalizados);
router.get('/respostasCamposPersonalizados/:id', respCamposPersonalizadosEventoController.visualizarRespostaCampoPersonalizado);

module.exports = router;
