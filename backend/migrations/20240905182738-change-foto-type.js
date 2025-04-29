'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.changeColumn('USUARIOS', 'FOTO_PERFIL', {
      type: Sequelize.TEXT,
      allowNull: true, // or false, depending on your requirement
    });
  },

  down: async (queryInterface, Sequelize) => {
    // Revert back to the original type (for example, BLOB or STRING)
    await queryInterface.changeColumn('USUARIOS', 'FOTO_PERFIL', {
      type: Sequelize.STRING, // or the original type
      allowNull: true, // or the original setting
    });
  },
};
