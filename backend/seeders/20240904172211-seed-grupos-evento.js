'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    // Inserting data into GRUPOS_EVENTO table
    await queryInterface.bulkInsert('GRUPOS_EVENTO', [
      {
        NOME: 'PÚBLICO EXTERNO',
        CNPJ: '00000000000000',
        QTD_USUARIOS: '0',
        SITUACAO: true, // Assuming the default value of 'SITUACAO' is true
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        NOME: 'FAPTO',
        CNPJ: '06343763000111',
        QTD_USUARIOS: '0',
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        NOME: 'UFT',
        CNPJ: '05149726000104',
        QTD_USUARIOS: '0',
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      }
    ], {});
  },

  async down (queryInterface, Sequelize) {
    // Removing data from GRUPOS_EVENTO table
    await queryInterface.bulkDelete('GRUPOS_EVENTO', {
      CNPJ: [
        '00000000000000',
        '06343763000111',
        '05149726000104'
      ]
    }, {});
  }
};
