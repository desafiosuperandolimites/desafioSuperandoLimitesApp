const express = require('express');
const router = express.Router();
const StatusPagamentoController = require('../controllers/statusPagamentoController');

router.get('/statusPagamento', StatusPagamentoController.listarStatusPagamento);

module.exports = router;
