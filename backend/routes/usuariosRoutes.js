const express = require('express');
const router = express.Router();
const usuariosController = require('../controllers/usuariosController');
const authenticateUser = require('../middleware/auth');
const checkPermissions = require('../middleware/checkPermissions');

// Routes for user management
router.use(authenticateUser);
router.use(checkPermissions);
router.get('/usuarios', usuariosController.listarUsuarios);
router.put('/usuarios/:id', usuariosController.editarUsuario);
router.get('/usuarios/:id', usuariosController.visualizarDadosUsuario);
router.patch('/usuarios/:id/ativar-desativar', usuariosController.ativarDesativarUsuario);
router.delete('/usuarios/:id', usuariosController.deletarUsuario);

module.exports = router;
