const express = require('express');
const router = express.Router();
const eventosController = require('../controllers/eventoController');

router.post('/eventos/criar', eventosController.criarEvento)
router.get('/eventos', eventosController.listarEventos);
router.put('/eventos/:id', eventosController.editarEvento);
router.get('/eventos/:id', eventosController.visualizarDadosEvento);
router.patch('/eventos/:id/ativar-desativar', eventosController.ativarDesativarEvento);
router.patch('/eventos/:id/isentar-nao-isentar', eventosController.isentarNaoIsentarEvento);
router.delete('/eventos/:id', eventosController.deletarEvento);
router.get('/eventos-por-grupo', eventosController.listarEventosGrupoHomePage);

module.exports = router;
