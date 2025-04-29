'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('ENDERECOS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      CEP: {
        type: Sequelize.STRING(8),
        allowNull: false
      },
      UF: {
        type: Sequelize.STRING(2),
        allowNull: false
      },
      CIDADE: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      LOGRADOURO: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      COMPLEMENTO: {
        type: Sequelize.STRING(255),
        allowNull: true
      },
      BAIRRO: {
        type: Sequelize.STRING(255),
        allowNull: true
      },
      NUMERO: {
        type: Sequelize.INTEGER,
        allowNull: true
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
    await queryInterface.dropTable('ENDERECOS');
  }
};