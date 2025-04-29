'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.changeColumn('PREMIACOES_EVENTO', 'TIPO', {
      type: Sequelize.STRING(255),
      allowNull: true
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.changeColumn('PREMIACOES_EVENTO', 'TIPO', {
      type: Sequelize.STRING(255),
      allowNull: false
    });
  },
};
