// seeders/20231010120001-seed-tipo-campo.js

'use strict';

const TipoCampoEnum = require('../enums/tipoCampoEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('TIPO_CAMPO', [
      {
        DESCRICAO: TipoCampoEnum.DROPDOWN.description,
        CHAVENOME: TipoCampoEnum.DROPDOWN.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: TipoCampoEnum.RADIOBUTTON.description,
        CHAVENOME: TipoCampoEnum.RADIOBUTTON.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: TipoCampoEnum.TEXT.description,
        CHAVENOME: TipoCampoEnum.TEXT.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('TIPO_CAMPO', null, {});
  },
};
