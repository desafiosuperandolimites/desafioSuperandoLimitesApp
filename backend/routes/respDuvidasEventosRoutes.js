const express = require('express');
const router = express.Router();
const respDuvidasEventosController = require('../controllers/respDuvidasEventosController');

router.post('/respDuvidasEventos', respDuvidasEventosController.adicionarRespostaDuvida);
router.put('/respDuvidasEventos/:id', respDuvidasEventosController.editarRespostaDuvida);
router.delete('/respDuvidasEventos/:id', respDuvidasEventosController.removerRespostaDuvida);
router.get('/respDuvidasEventos', respDuvidasEventosController.listarRespostasDuvida);
router.get('/respDuvidasEventos/:id', respDuvidasEventosController.visualizarRespostaDuvida);

module.exports = router;
