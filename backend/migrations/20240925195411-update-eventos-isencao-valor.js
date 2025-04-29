'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Add new columns
    await queryInterface.addColumn('EVENTOS', 'ISENTO_PAGAMENTO', {
      type: Sequelize.BOOLEAN,
      allowNull: true,
    });

    await queryInterface.addColumn('EVENTOS', 'VALOR_EVENTO', {
      type: Sequelize.Sequelize.DECIMAL(10, 2),
      allowNull: true,
    });
  },

  down: async (queryInterface, Sequelize) => {
        // Remove the new columns
    await queryInterface.removeColumn('EVENTOS', 'ISENTO_PAGAMENTO');
    await queryInterface.removeColumn('EVENTOS', 'VALOR_EVENTO');
  },
};