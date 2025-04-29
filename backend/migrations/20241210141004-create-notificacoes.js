'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('NOTIFICACOES', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
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
      TITLE: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      BODY: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      LIDA: {
        type: Sequelize.BOOLEAN,
        defaultValue: false,
        allowNull: false,
      },
      CRIADO_EM: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      },
      ATUALIZADO_EM: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.NOW,
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('NOTIFICACOES');
  }
};
