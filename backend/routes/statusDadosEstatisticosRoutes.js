const express = require('express');
const router = express.Router();
const statusDadosEstatisticosController = require('../controllers/statusDadosEstatisticosController');

router.get('/statusDadosEstatisticos', statusDadosEstatisticosController.listarStatusDadosEstatisticos);

module.exports = router;
