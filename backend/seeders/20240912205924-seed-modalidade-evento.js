'use strict';

const ModalidadeTipoEnum = require('../enums/modalidadeEventoEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('MODALIDADES_EVENTOS', [
      { DESCRICAO: ModalidadeTipoEnum.BIKE.description, CHAVE_NOME: ModalidadeTipoEnum.BIKE.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: ModalidadeTipoEnum.RUN_WALK.description, CHAVE_NOME: ModalidadeTipoEnum.RUN_WALK.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: ModalidadeTipoEnum.BOTH.description, CHAVE_NOME: ModalidadeTipoEnum.BOTH.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('MODALIDADES_EVENTOS', null, {});
  }
};