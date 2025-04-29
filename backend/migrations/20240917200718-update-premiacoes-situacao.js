'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('PREMIACOES_EVENTO', 'SITUACAO', {
      type: Sequelize.BOOLEAN,  
      defaultValue: true
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('PREMIACOES_EVENTO', 'SITUACAO');
  }
};