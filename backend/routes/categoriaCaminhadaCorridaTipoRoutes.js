// routes/categoriaCaminhadaCorridaRoutes.js

const express = require('express');
const router = express.Router();
const categoriaCaminhadaCorridaController = require('../controllers/categoriaCaminhadaCorridaController');

// Rota para criar uma nova categoria
router.post('/categoriaCaminhadaCorrida', categoriaCaminhadaCorridaController.createCategoria);

// Rota para obter todas as categorias
router.get('/categoriasCaminhadaCorrida', categoriaCaminhadaCorridaController.getCategorias);


module.exports = router;
