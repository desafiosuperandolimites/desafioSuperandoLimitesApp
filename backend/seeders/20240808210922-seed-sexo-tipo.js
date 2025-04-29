'use strict';

const SexoTipoEnum = require('../enums/sexoTipoEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('SEXO_TIPO', [
      { DESCRICAO: SexoTipoEnum.MAS.description, CHAVE: SexoTipoEnum.MAS.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: SexoTipoEnum.FEM.description, CHAVE: SexoTipoEnum.FEM.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: SexoTipoEnum.NAO.description, CHAVE: SexoTipoEnum.NAO.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('SEXO_TIPO', null, {});
  }
};
