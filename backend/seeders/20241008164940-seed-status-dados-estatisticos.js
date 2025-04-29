'use strict';

const StatusDadosEstatisticosEnum = require('../enums/statusDadosEstatisticosEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('STATUS_DADOS_ESTATISTICOS', [
      {
        DESCRICAO: StatusDadosEstatisticosEnum.PENDENTE_APROVACAO.description,
        CHAVENOME: StatusDadosEstatisticosEnum.PENDENTE_APROVACAO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusDadosEstatisticosEnum.PENDENTE_CORRECAO.description,
        CHAVENOME: StatusDadosEstatisticosEnum.PENDENTE_CORRECAO.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
      {
        DESCRICAO: StatusDadosEstatisticosEnum.APROVADA.description,
        CHAVENOME: StatusDadosEstatisticosEnum.APROVADA.key,
        SITUACAO: true,
        CRIADO_EM: new Date(),
        ATUALIZADO_EM: new Date(),
      },
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('STATUS_DADOS_ESTATISTICOS', null, {});
  },
};
