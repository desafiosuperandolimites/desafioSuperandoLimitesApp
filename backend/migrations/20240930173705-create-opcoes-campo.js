'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('OPCOES_CAMPO', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      ID_CAMPOS_PERSONALIZADOS: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'CAMPOS_PERSONALIZADOS',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      OPCAO: {
        type: Sequelize.STRING,
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
    await queryInterface.dropTable('OPCOES_CAMPO');
  },
};
