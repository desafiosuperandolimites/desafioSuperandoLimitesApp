'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('PERFIS_TIPO', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      DESCRICAO: {
        type: Sequelize.STRING(250),
        allowNull: false
      },
      CHAVE: {
        type: Sequelize.STRING(3),
        allowNull: false
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      CRIADO_EM: {
        allowNull: false,
        type: Sequelize.DATE
      },
      ATUALIZADO_EM: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('PERFIS_TIPO');
  }
};