const express = require('express');
const router = express.Router();
const estadosCivisTipoController = require('../controllers/estadosCivisTipoController');

router.post('/estadoCivilTipo', estadosCivisTipoController.createEstadosCivisTipo);
router.get('/estadosCivisTipos', estadosCivisTipoController.getEstadosCivisTipos);

module.exports = router;