'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('MODALIDADES_EVENTOS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      DESCRICAO: {
        type: Sequelize.STRING(155),
        allowNull: false
      },
      CHAVE_NOME: {
        type: Sequelize.STRING(255),
        allowNull: false,
        unique: true
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true
      },
      CRIADO_EM: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      ATUALIZADO_EM: {
        type: Sequelize.DATE,
        allowNull: true
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('MODALIDADES_EVENTOS');
  }
};
