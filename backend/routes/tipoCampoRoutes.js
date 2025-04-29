const express = require('express');
const router = express.Router();
const tipoCampoController = require('../controllers/tipoCampoController');

router.get('/tipoCampo', tipoCampoController.listarTiposCampo);

module.exports = router;
