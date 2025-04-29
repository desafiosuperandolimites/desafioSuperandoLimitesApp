'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('PREMIACOES_EVENTO', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      NOME: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      DESCRICAO: {
        type: Sequelize.STRING(255),
        allowNull: true
      },
      TIPO: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      CRIADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
      },
      ATUALIZADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('PREMIACOES_EVENTO');
  }
};