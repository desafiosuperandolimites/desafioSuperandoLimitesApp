'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('EVENTOS', 'ID_DURACAO_EVENTO');
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('EVENTOS', 'ID_DURACAO_EVENTO',{
      type: Sequelize.INTEGER,
      allowNull: true, // Changed from false to true
      references: {
        model: 'DURACOES_EVENTO_TIPO', // Table name for DuracaoEvento
        key: 'ID',
      },
      onUpdate: 'CASCADE',
      onDelete: 'RESTRICT',
    });
  }
};
