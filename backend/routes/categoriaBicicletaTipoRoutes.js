// routes/categoriaBicicletaRoutes.js

const express = require('express');
const router = express.Router();
const categoriaBicicletaController = require('../controllers/categoriaBicicletaController');

// Rota para criar uma nova categoria
router.post('/categoriaBicicleta', categoriaBicicletaController.createCategoria);

// Rota para obter todas as categorias
router.get('/categoriasBicicleta', categoriaBicicletaController.getCategorias);



module.exports = router;
