// migrations/20231010120000-create-tipo-campo.js

'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('TIPO_CAMPO', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      DESCRICAO: {
        type: Sequelize.STRING(250),
        allowNull: false,
      },
      CHAVENOME: {
        type: Sequelize.STRING(50),
        allowNull: false,
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        defaultValue: true,
      },
      CRIADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
      ATUALIZADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('TIPO_CAMPO');
  },
};
