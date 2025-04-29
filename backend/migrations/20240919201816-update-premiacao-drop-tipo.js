'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('PREMIACOES_EVENTO', 'TIPO');
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('PREMIACOES_EVENTO', 'TIPO', {
      type: Sequelize.STRING(255),
      allowNull: true
    });
  }
};