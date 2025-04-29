'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('USUARIOS', 'ALTURA', {
      type: Sequelize.DECIMAL(5, 2),
      allowNull: true
    });

    await queryInterface.addColumn('USUARIOS', 'PESO', {
      type: Sequelize.DECIMAL(5, 2),
      allowNull: true
    });

    await queryInterface.addColumn('USUARIOS', 'CADASTRO_PENDENTE', {
      type: Sequelize.BOOLEAN,
      defaultValue: false,
      allowNull: false
    });

    await queryInterface.addColumn('USUARIOS', 'PAGAMENTO_PENDENTE', {
      type: Sequelize.BOOLEAN,
      defaultValue: false,
      allowNull: false
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('USUARIOS', 'ALTURA');
    await queryInterface.removeColumn('USUARIOS', 'PESO');
    await queryInterface.removeColumn('USUARIOS', 'CADASTRO_PENDENTE');
    await queryInterface.removeColumn('USUARIOS', 'PAGAMENTO_PENDENTE');
  }
};