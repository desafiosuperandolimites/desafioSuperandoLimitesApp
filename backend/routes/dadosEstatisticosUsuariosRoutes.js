const express = require('express');
const router = express.Router();
const dadosController = require('../controllers/dadosEstatisticosUsuariosController');

// Rotas para usuários
router.post('/dadosEstatisticos', dadosController.adicionarDadosEstatisticos);
router.put('/dadosEstatisticos/:id', dadosController.editarDadosEstatisticos);
router.get('/dadosEstatisticos', dadosController.listarDadosEstatisticosUsuario);
router.put('/dadosEstatisticos/cancelar/:id', dadosController.cancelarDadosEstatisticos);

// Rotas para administradores
router.put('/dadosEstatisticos/aprovar/:id', dadosController.aprovarDadosEstatisticos);
router.put('/dadosEstatisticos/rejeitar/:id', dadosController.rejeitarDadosEstatisticos);
router.post('/dadosEstatisticos/admin', dadosController.registrarKMAdmin);
router.get('/dadosEstatisticos/evento', dadosController.listarDadosEstatisticosEvento);

module.exports = router;
