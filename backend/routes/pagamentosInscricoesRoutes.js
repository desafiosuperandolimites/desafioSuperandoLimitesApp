const express = require('express');
const router = express.Router();
const pagamentoInscricaoController = require('../controllers/pagamentosInscricoesController');

// Rota para adicionar um novo pagamento
router.post('/pagamentoInscricao', pagamentoInscricaoController.adicionarPagamentoInscricao);

// Rota para editar um pagamento existente
router.put('/pagamentoInscricao/:id', pagamentoInscricaoController.editarPagamentoInscricao);

// Rota para remover um pagamento existente
router.delete('/pagamentoInscricao/:id', pagamentoInscricaoController.removerPagamentoInscricao);

// Rota para listar todos os pagamentos
router.get('/pagamentosInscricao', pagamentoInscricaoController.listarPagamentosInscricao);

// Rota para visualizar os dados de um pagamento específico
router.get('/pagamentosInscricao/:id', pagamentoInscricaoController.visualizarDadosPagamento);

// Rota para aprovar pagamento
router.put('/pagamentoInscricao/:id/aprovar', pagamentoInscricaoController.aprovarPagamentoInscricao);

// Rota para rejeitar pagamento
router.put('/pagamentoInscricao/:id/rejeitar', pagamentoInscricaoController.rejeitarPagamentoInscricao);

// Rota para buscar pagamento por ID_INSCRICAO_EVENTO
router.get('/pagamentosInscricao/inscricao/:idInscricaoEvento', pagamentoInscricaoController.buscarPagamentoPorInscricao);


module.exports = router;
