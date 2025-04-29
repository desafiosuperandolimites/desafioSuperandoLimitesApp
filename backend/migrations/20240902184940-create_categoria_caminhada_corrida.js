'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('CATEGORIA_CAMINHADA_CORRIDA', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      DISTANCIA: {
        type: Sequelize.STRING(10),
        allowNull: false
      },
      CHAVE: {
        type: Sequelize.STRING(20),
        allowNull: false
      },
      DESCRICAO: {
        type: Sequelize.STRING(250),
        allowNull: false
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      CRIADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      ATUALIZADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('CATEGORIA_CAMINHADA_CORRIDA');
  }
};
