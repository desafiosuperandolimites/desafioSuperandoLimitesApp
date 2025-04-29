const express = require('express');
const router = express.Router();
const enderecoController = require('../controllers/enderecoController');

router.post('/enderecos', enderecoController.adicionarEndereco);
router.delete('/enderecos/:id', enderecoController.removerEndereco);
router.put('/enderecos/:id', enderecoController.editarEndereco);
router.get('/enderecos/:id', enderecoController.visualizarEndereco);

module.exports = router;