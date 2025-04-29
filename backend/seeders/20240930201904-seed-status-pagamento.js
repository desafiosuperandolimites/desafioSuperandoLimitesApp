'use strict';

const StatusPagamentoEnum = require('../enums/statusPagamentoTipoEnum');


module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('STATUS_PAGAMENTO', [
      {
        DESCRICAO: StatusPagamentoEnum.NAO_PAGO.description,
        CHAVENOME: StatusPagamentoEnum.NAO_PAGO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusPagamentoEnum.PAGO.description,
        CHAVENOME: StatusPagamentoEnum.PAGO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusPagamentoEnum.REVISAR_COMPROVANTE.description,
        CHAVENOME: StatusPagamentoEnum.REVISAR_COMPROVANTE.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusPagamentoEnum.CANCELADO.description,
        CHAVENOME: StatusPagamentoEnum.CANCELADO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusPagamentoEnum.ISENTO.description,
        CHAVENOME: StatusPagamentoEnum.ISENTO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('STATUS_PAGAMENTO', null, {});
  },
};
