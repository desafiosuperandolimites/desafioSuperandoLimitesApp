'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Remove the DATA_DESAFIO column
    await queryInterface.removeColumn('EVENTOS', 'DATA_DESAFIO');

    // Add new columns
    await queryInterface.addColumn('EVENTOS', 'DATA_INICIO_DESAFIO', {
      type: Sequelize.DATE,
      allowNull: true,
    });

    await queryInterface.addColumn('EVENTOS', 'DATA_FIM_DESAFIO', {
      type: Sequelize.DATE,
      allowNull: true,
    });

    await queryInterface.addColumn('EVENTOS', 'DATA_INICIO_INSCRICAO', {
      type: Sequelize.DATE,
      allowNull: true,
    });

    await queryInterface.addColumn('EVENTOS', 'DATA_FIM_INSCRICAO', {
      type: Sequelize.DATE,
      allowNull: true,
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Add the DATA_DESAFIO column back
    await queryInterface.addColumn('EVENTOS', 'DATA_DESAFIO', {
      type: Sequelize.STRING(100),
      allowNull: true,
    });

    // Remove the new columns
    await queryInterface.removeColumn('EVENTOS', 'DATA_INICIO_DESAFIO');
    await queryInterface.removeColumn('EVENTOS', 'DATA_FIM_DESAFIO');
    await queryInterface.removeColumn('EVENTOS', 'DATA_INICIO_INSCRICAO');
    await queryInterface.removeColumn('EVENTOS', 'DATA_FIM_INSCRICAO');
  },
};