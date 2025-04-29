const express = require('express');
const router = express.Router();
const depoimentosController = require('../controllers/depoimentosController');

router.post('/depoimentos', depoimentosController.criarDepoimento);
router.put('/depoimentos/:id', depoimentosController.editarDepoimento);
router.delete('/depoimentos/:id', depoimentosController.deletarDepoimento);
router.get('/depoimentos', depoimentosController.listarDepoimentos);
router.get('/depoimentos/:id', depoimentosController.visualizarDepoimento);
router.patch('/depoimentos/:id/ativar-desativar', depoimentosController.ativarDesativarDepoimento);

module.exports = router;
