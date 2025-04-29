const express = require('express');
const router = express.Router();
const inscricaoEventoController = require('../controllers/inscricaoEventoController');

// Criar uma nova inscrição
router.post('/inscricoes/criar', inscricaoEventoController.criarInscricao);

// Listar todas as inscrições com opções de busca, ordenação e filtragem
router.get('/inscricoes', inscricaoEventoController.listarInscricoes);

// Listar todas as inscrições com opções de busca, ordenação e filtragem
router.get('/inscricoes/eventos', inscricaoEventoController.listarInscricoesByEvento);

// Editar uma inscrição específica
router.put('/inscricoes/:id', inscricaoEventoController.editarInscricao);

// Medalha entregue ou não
router.put('/inscricoes/:id/entregue', inscricaoEventoController.medalhaEntregue);

// Visualizar uma inscrição específica
router.get('/inscricoes/:id', inscricaoEventoController.visualizarDadosInscricao);

// Excluir uma inscrição específica
router.delete('/inscricoes/:id', inscricaoEventoController.deletarInscricao);



module.exports = router;
