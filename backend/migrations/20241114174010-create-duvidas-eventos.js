'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('DUVIDAS_EVENTOS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      ID_USUARIO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'USUARIOS',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      DUVIDA: {
        type: Sequelize.STRING(500),
        allowNull: false,
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        defaultValue: true, // 'true' represents 'ativa'
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
    await queryInterface.dropTable('DUVIDAS_EVENTOS');
  },
};
