'use strict';

const EstadoCivilEnum = require('../enums/estadoCivilEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('ESTADOS_CIVIS_TIPO', [
      { DESCRICAO: EstadoCivilEnum.SOL.description, CHAVE: EstadoCivilEnum.SOL.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: EstadoCivilEnum.CAS.description, CHAVE: EstadoCivilEnum.CAS.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: EstadoCivilEnum.SEP.description, CHAVE: EstadoCivilEnum.SEP.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: EstadoCivilEnum.DIV.description, CHAVE: EstadoCivilEnum.DIV.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() },
      { DESCRICAO: EstadoCivilEnum.VIU.description, CHAVE: EstadoCivilEnum.VIU.key, SITUACAO: true, CRIADO_EM: new Date(), ATUALIZADO_EM: new Date() }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('ESTADOS_CIVIS_TIPO', null, {});
  }
};
