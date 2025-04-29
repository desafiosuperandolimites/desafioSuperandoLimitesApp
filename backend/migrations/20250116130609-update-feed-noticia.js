'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('FEED_NOTICIAS', 'SHARE_TOKEN', {
      type: Sequelize.STRING(255),
      allowNull: true
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('FEED_NOTICIAS', 'SHARE_TOKEN');
  }
};