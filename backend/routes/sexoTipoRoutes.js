// backend/routes/sexoTipoRoutes.js

const express = require('express');
const router = express.Router();
const sexoTipoController = require('../controllers/sexoTipoController');

router.post('/sexoTipo', sexoTipoController.createSexoTipo);
router.get('/sexoTipos', sexoTipoController.getSexoTipos);

module.exports = router;
