'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('DADOS_BANCARIOS_ADM', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
      },
      ID_USUARIO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'USUARIOS',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      AGENCIA: {
        type: Sequelize.STRING(500),
        allowNull: false
      },
      CONTA: {
        type: Sequelize.STRING(500),
        allowNull: false
      },
      TITULAR: {
        type: Sequelize.STRING(500),
        allowNull: false
      },
      BANCO: {
        type: Sequelize.STRING(500),
        allowNull: false
      },
      PIX: {
        type: Sequelize.STRING,
        allowNull: true
      },
      DATA_PAGAMENTO: {
        type: Sequelize.DATE,
        allowNull: true
      },
      DATA_ATUALIZACAO: {
        type: Sequelize.DATE,
        allowNull: true
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('DADOS_BANCARIOS_ADM');
  }
};
