// migrations/20231010123000-create-campos-personalizados.js

'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('CAMPOS_PERSONALIZADOS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      ID_GRUPOS_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'GRUPOS_EVENTO',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      ID_TIPO_CAMPO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'TIPO_CAMPO',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT',
      },
      NOME_CAMPO: {
        type: Sequelize.STRING(155),
        allowNull: false,
      },
      OBRIGATORIO: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
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
    await queryInterface.dropTable('CAMPOS_PERSONALIZADOS');
  },
};
