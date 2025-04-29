'use strict';

const DuracaoEventoEnum = require('../enums/DuracaoEventoTipoEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('DURACOES_EVENTO_TIPO', [
      { DESCRICAO: DuracaoEventoEnum.UM_DIA.description, CHAVE_NOME: DuracaoEventoEnum.UM_DIA.key, SITUACAO: true, DATA_CRIACAO: new Date(), DATA_ATUALIZACAO: new Date() },
      { DESCRICAO: DuracaoEventoEnum.DOIS_DIAS.description, CHAVE_NOME: DuracaoEventoEnum.DOIS_DIAS.key, SITUACAO: true, DATA_CRIACAO: new Date(), DATA_ATUALIZACAO: new Date() },
      { DESCRICAO: DuracaoEventoEnum.TRES_DIAS.description, CHAVE_NOME: DuracaoEventoEnum.TRES_DIAS.key, SITUACAO: true, DATA_CRIACAO: new Date(), DATA_ATUALIZACAO: new Date() },
      { DESCRICAO: DuracaoEventoEnum.SETE_DIAS.description, CHAVE_NOME: DuracaoEventoEnum.SETE_DIAS.key, SITUACAO: true, DATA_CRIACAO: new Date(), DATA_ATUALIZACAO: new Date() },
      { DESCRICAO: DuracaoEventoEnum.TRINTA_DIAS.description, CHAVE_NOME: DuracaoEventoEnum.TRINTA_DIAS.key, SITUACAO: true, DATA_CRIACAO: new Date(), DATA_ATUALIZACAO: new Date() },
      { DESCRICAO: DuracaoEventoEnum.NOVENTA_DIAS.description, CHAVE_NOME: DuracaoEventoEnum.NOVENTA_DIAS.key, SITUACAO: true, DATA_CRIACAO: new Date(), DATA_ATUALIZACAO: new Date() },
      { DESCRICAO: DuracaoEventoEnum.CENTO_E_OITENTA_DIAS.description, CHAVE_NOME: DuracaoEventoEnum.CENTO_E_OITENTA_DIAS.key, SITUACAO: true, DATA_CRIACAO: new Date(), DATA_ATUALIZACAO: new Date() },
      { DESCRICAO: DuracaoEventoEnum.TREZENTOS_E_SESSENTA_E_CINCO_DIAS.description, CHAVE_NOME: DuracaoEventoEnum.TREZENTOS_E_SESSENTA_E_CINCO_DIAS.key, SITUACAO: true, DATA_CRIACAO: new Date(), DATA_ATUALIZACAO: new Date() }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('DURACOES_EVENTO_TIPO', null, {});
  }
};