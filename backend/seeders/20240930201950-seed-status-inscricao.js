'use strict';

const StatusInscricaoEnum = require('../enums/statusInscricaoTipoEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('STATUS_INSCRICAO', [
      {
        DESCRICAO: StatusInscricaoEnum.PENDENTE_PAGAMENTO.description,
        CHAVENOME: StatusInscricaoEnum.PENDENTE_PAGAMENTO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusInscricaoEnum.PENDENTE_APROVACAO.description,
        CHAVENOME: StatusInscricaoEnum.PENDENTE_APROVACAO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusInscricaoEnum.PAGA.description,
        CHAVENOME: StatusInscricaoEnum.PAGA.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusInscricaoEnum.AGUARDANDO_REVISAO.description,
        CHAVENOME: StatusInscricaoEnum.AGUARDANDO_REVISAO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusInscricaoEnum.CANCELADO.description,
        CHAVENOME: StatusInscricaoEnum.CANCELADO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusInscricaoEnum.MOVIDO_GRUPO.description,
        CHAVENOME: StatusInscricaoEnum.MOVIDO_GRUPO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusInscricaoEnum.ISENTA.description,
        CHAVENOME: StatusInscricaoEnum.ISENTA.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('STATUS_INSCRICAO', null, {});
  },
};
