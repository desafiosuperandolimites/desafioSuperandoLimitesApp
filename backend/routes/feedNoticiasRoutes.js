const express = require('express');
const router = express.Router();
const path = require('path');
const feedNoticiasController = require('../controllers/feedNoticiasController');

// Public routes
router.get('/noticias/listar', feedNoticiasController.listarNoticias);
router.get('/noticias/:id', feedNoticiasController.visualizarNoticia);

// Routes requiring admin or assistant admin privileges
router.post('/noticias/criar', feedNoticiasController.criarNoticia);
router.put('/noticias/:id', feedNoticiasController.editarNoticia);
router.delete('/noticias/:id', feedNoticiasController.removerNoticia);

// NOVA ROTA: gerar link de compartilhamento
router.post('/noticias/:id/share', feedNoticiasController.gerarLinkCompartilhamento);

// NOVA ROTA: redirecionar ao clicar no link
// Observação: Se quiser deixar esse endpoint "público", defina-o sem prefixo de "noticias"
router.get('/share/:shareToken', feedNoticiasController.redirecionarNoticia);

// Nova rota para obter notícia por shareToken
router.get('/noticias/token/:shareToken', feedNoticiasController.getNoticiaByShareToken);

module.exports = router;
