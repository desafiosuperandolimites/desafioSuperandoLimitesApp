'use strict';

const PerfisTipoEnum = require('../enums/perfisTipoEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('PERFIS_TIPO', [
      { DESCRICAO: PerfisTipoEnum.ADM.description, CHAVE: PerfisTipoEnum.ADM.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: PerfisTipoEnum.ASS.description, CHAVE: PerfisTipoEnum.ASS.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: PerfisTipoEnum.USU.description, CHAVE: PerfisTipoEnum.USU.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('PERFIS_TIPO', null, {});
  }
};
