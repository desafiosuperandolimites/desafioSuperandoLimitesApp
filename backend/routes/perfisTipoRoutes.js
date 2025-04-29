const express = require('express');
const router = express.Router();
const perfisTipoController = require('../controllers/perfisTipoController');

router.post('/perfisTipo', perfisTipoController.createPerfisTipo);
router.get('/perfisTipos', perfisTipoController.getPerfisTipos);

module.exports = router;