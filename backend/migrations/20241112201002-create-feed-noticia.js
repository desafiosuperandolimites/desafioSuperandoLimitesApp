'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('FEED_NOTICIAS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
      },
      ID_USUARIO: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      CATEGORIA: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      TITULO: {
        type: Sequelize.STRING(100),
        allowNull: false,
      },
      DESCRICAO: {
        type: Sequelize.STRING(200),
        allowNull: false,
      },
      FOTO_CAPA: {
        type: Sequelize.STRING,
        allowNull: true,
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
      },
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('FEED_NOTICIAS');
  },
};
