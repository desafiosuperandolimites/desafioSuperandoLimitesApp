'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    // Alter the 'ID_DURACAO_EVENTO' column to allow NULL values
    await queryInterface.changeColumn('EVENTOS', 'ID_DURACAO_EVENTO', {
      type: Sequelize.INTEGER,
      allowNull: true, // Changed from false to true
      references: {
        model: 'DURACOES_EVENTO_TIPO', // Table name for DuracaoEvento
        key: 'ID',
      },
      onUpdate: 'CASCADE',
      onDelete: 'RESTRICT',
    });
  },


  down: async (queryInterface, Sequelize) => {
    // Revert the 'ID_DURACAO_EVENTO' column to NOT NULL
    await queryInterface.changeColumn('EVENTOS', 'ID_DURACAO_EVENTO', {
      type: Sequelize.INTEGER,
      allowNull: false, // Changed back to false
      references: {
        model: 'DURACOES_EVENTO_TIPO', // Table name for DuracaoEvento
        key: 'ID',
      },
      onUpdate: 'CASCADE',
      onDelete: 'RESTRICT',
    });
  },
};