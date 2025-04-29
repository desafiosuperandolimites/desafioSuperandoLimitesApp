'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('USUARIOS', 'RG');

  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('USUARIOS', 'RG', {
      type: Sequelize.STRING(14),
      allowNull: true
    });
  }
}
