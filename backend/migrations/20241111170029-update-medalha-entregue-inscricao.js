'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Add new columns
    await queryInterface.addColumn('INSCRICOES_EVENTOS', 'MEDALHA_ENTREGUE', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });

  },

  down: async (queryInterface, Sequelize) => {
    // Remove the new columns
    await queryInterface.removeColumn('INSCRICOES_EVENTOS', 'MEDALHA_ENTREGUE');

  },
};