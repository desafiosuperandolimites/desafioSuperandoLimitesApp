// routes/index.js

const express = require('express');
const router = express.Router();


// Importar as rotas
const categoriaBicicletaRoutes = require('./categoriaBicicletaTipoRoutes');
const categoriaCaminhadaCorridaRoutes = require('./categoriaCaminhadaCorridaTipoRoutes');
const sexoTipoRoutes = require('./sexoTipoRoutes');
const estadosCivisTipoRoutes = require('./estadosCivisTipoRoutes');
const perfisTipoRoutes = require('./perfisTipoRoutes');
const enderecoRoutes = require('./enderecoRoutes');
const cadastroRoutes = require('./cadastroRoutes');
const cadastroAdminRoutes = require('./cadastroAdminRoutes');
const gruposEventoRoutes = require('./gruposEventoRoutes');
const authRoutes = require('./authRoutes');
const recuperarSenhaRoutes = require('./recuperarSenhaRoutes');
const premiacaoRoutes = require('./premiacaoRoutes');
const eventosRoutes = require('./eventosRoutes');
const dadosBancariosAdmRoutes = require('./dadosBancariosAdmRoutes');
const tipoCampoRoutes = require('./tipoCampoRoutes');
const camposPersonalizadosRoutes = require('./camposPersonalizadosRoutes');
const opcoesCampoRoutes = require('./opcoesCampoRoutes');
const respCamposPersonalizadosEventoRoutes = require('./respCamposPersonalizadosEventoRoutes');
const inscricaoEventoRoutes = require('./inscricaoEventoRoutes');
const pagamentoInscricaoRoutes = require('./pagamentosInscricoesRoutes');
const StatusPagamentoRoutes = require('./statusPagamentoRoutes');
const statusDadosEstatisticosRoutes = require('./statusDadosEstatisticosRoutes');
const usuariosRoutes = require('./usuariosRoutes');
const dadosEstatisticosUsuariosRoutes = require('./dadosEstatisticosUsuariosRoutes');
const feedNoticiasRoutes = require('./feedNoticiasRoutes');
const duvidasEventosRoutes = require('./duvidasEventosRoutes');
const respDuvidasEventosRoutes = require('./respDuvidasEventosRoutes');
const depoimentosRoutes = require('./depoimentosRoutes');
const notificacoesRoutes = require('./notificacoesRoutes');
const fileRoutes = require('./fileRoutes');
const googleAuthRoutes = require('./googleAuthRoutes');

// Usa as rotas agrupadas
router.use(categoriaCaminhadaCorridaRoutes);
router.use(categoriaBicicletaRoutes);
router.use(sexoTipoRoutes);
router.use(estadosCivisTipoRoutes);
router.use(perfisTipoRoutes);
router.use(enderecoRoutes);
router.use(cadastroRoutes);
router.use(gruposEventoRoutes);
router.use('/auth', authRoutes);
router.use(recuperarSenhaRoutes);
router.use(premiacaoRoutes);
router.use(eventosRoutes);
router.use(dadosBancariosAdmRoutes);
router.use(tipoCampoRoutes);
router.use(camposPersonalizadosRoutes);
router.use(opcoesCampoRoutes);
router.use(respCamposPersonalizadosEventoRoutes);
router.use(inscricaoEventoRoutes);
router.use(pagamentoInscricaoRoutes);
router.use(statusDadosEstatisticosRoutes);
router.use(StatusPagamentoRoutes);
router.use(feedNoticiasRoutes);
router.use(duvidasEventosRoutes);
router.use(respDuvidasEventosRoutes);
router.use(depoimentosRoutes);
router.use(notificacoesRoutes);
router.use('/files/', fileRoutes);
router.use(googleAuthRoutes);
router.use(usuariosRoutes);
router.use(cadastroAdminRoutes);
router.use(dadosEstatisticosUsuariosRoutes);

module.exports = router;
