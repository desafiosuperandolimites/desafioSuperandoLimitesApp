const express = require('express');
const router = express.Router();
const gruposEventoController = require('../controllers/gruposEventoController');

router.post('/grupoEvento', gruposEventoController.adicionarGrupoEvento);
router.put('/grupoEvento/:id', gruposEventoController.editarGrupoEvento);
router.delete('/grupoEvento/:id', gruposEventoController.removerGrupoEvento);
router.get('/gruposEvento', gruposEventoController.listarGrupoEvento);
router.get('/gruposEvento/:id', gruposEventoController.visualizarDadosGrupo);
router.patch('/gruposEvento/:id/ativar-desativar', gruposEventoController.ativarDesativarGrupo);

module.exports = router;