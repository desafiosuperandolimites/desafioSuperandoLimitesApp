'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('RESP_DUVIDAS_EVENTOS', {
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
      ID_DUVIDA_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'DUVIDAS_EVENTOS',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      RESPOSTA: {
        type: Sequelize.STRING(500),
        allowNull: false,
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
    await queryInterface.dropTable('RESP_DUVIDAS_EVENTOS');
  },
};
