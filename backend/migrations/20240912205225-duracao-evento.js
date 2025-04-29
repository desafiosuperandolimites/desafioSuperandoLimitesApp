'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('DURACOES_EVENTO_TIPO', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      DESCRICAO: {
        type: Sequelize.STRING(250),
        allowNull: false
      },
      CHAVE_NOME: {
        type: Sequelize.STRING(150),
        allowNull: false,
        unique: true
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true
      },
      DATA_CRIACAO: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      DATA_ATUALIZACAO: {
        type: Sequelize.DATE,
        allowNull: true
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('DURACOES_EVENTO_TIPO');
  }
};
