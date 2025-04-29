const express = require('express');
const router = express.Router();
const duvidasEventosController = require('../controllers/duvidasEventosController');

// Rotas
router.post('/duvidasEventos', duvidasEventosController.adicionarDuvida);
router.put('/duvidasEventos/:id', duvidasEventosController.editarDuvida);
router.delete('/duvidasEventos/:id', duvidasEventosController.removerDuvida);
router.get('/duvidasEventos', duvidasEventosController.listarDuvida);
router.get('/duvidasEventos/:id', duvidasEventosController.visualizarDuvida);
router.patch('/duvidasEventos/:id/ativar-desativar', duvidasEventosController.ativarDesativarDuvida);

module.exports = router;
