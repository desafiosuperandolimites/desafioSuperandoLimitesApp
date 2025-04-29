// routes/camposPersonalizadosRoutes.js

const express = require('express');
const router = express.Router();
const camposPersonalizadosController = require('../controllers/camposPersonalizadosController');

router.post('/camposPersonalizados', camposPersonalizadosController.adicionarCampoPersonalizado);
router.put('/camposPersonalizados/:id', camposPersonalizadosController.editarCampoPersonalizado);
router.delete('/camposPersonalizados/:id', camposPersonalizadosController.removerCampoPersonalizado);
router.get('/camposPersonalizados', camposPersonalizadosController.listarCamposPersonalizados);
router.get('/camposPersonalizados/:id', camposPersonalizadosController.visualizarCampoPersonalizado);
router.patch('/camposPersonalizados/:id/ativar-desativar', camposPersonalizadosController.ativarDesativarCampoPersonalizado);

module.exports = router;
