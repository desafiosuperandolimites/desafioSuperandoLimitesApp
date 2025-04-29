const express = require('express');
const router = express.Router();
const premiacaoController = require('../controllers/premiacaoController');

router.post('/premiacao', premiacaoController.adicionarPremiacao);
router.put('/premiacao/:id', premiacaoController.editarPremiacao);
router.delete('/premiacao/:id', premiacaoController.removerPremiacao);
router.get('/premiacao', premiacaoController.listarPremiacao);
router.get('/premiacao/:id', premiacaoController.visualizarDadosPremiacao);

module.exports = router;
