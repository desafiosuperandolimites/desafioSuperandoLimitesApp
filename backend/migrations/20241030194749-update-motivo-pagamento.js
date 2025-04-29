'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Add new columns
    await queryInterface.addColumn('PAGAMENTOS_INSCRICOES', 'MOTIVO', {
      type: Sequelize.STRING,
      allowNull: true,
    });

  },

  down: async (queryInterface, Sequelize) => {
    // Remove the new columns
    await queryInterface.removeColumn('PAGAMENTOS_INSCRICOES', 'MOTIVO');

  },
};