'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('GRUPOS_EVENTO', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      NOME: {
        type: Sequelize.STRING(250),
        allowNull: false
      },
      CNPJ: {
        type: Sequelize.STRING(14),
        allowNull: false
      },
      QTD_USUARIOS: {
        type: Sequelize.STRING(255),
        allowNull: true
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
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
    await queryInterface.dropTable('GRUPOS_EVENTO');
  }
};
