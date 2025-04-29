'use strict';

const CategoriaCaminhadaCorridaTipoEnum = require('../enums/CategoriaCaminhadaCorridaTipoEnum');

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.bulkInsert('CATEGORIA_CAMINHADA_CORRIDA', [
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.INICIANTE_30KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.INICIANTE_30KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.INICIANTE_30KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.INICIANTE_2_40KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.INICIANTE_2_40KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.INICIANTE_2_40KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.BRUTA_50KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.BRUTA_50KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.BRUTA_50KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.GALACTICA_60KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.GALACTICA_60KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.GALACTICA_60KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.INSANA_80KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.INSANA_80KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.INSANA_80KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.TOP_DAS_GALAXIAS_100KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.TOP_DAS_GALAXIAS_100KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.TOP_DAS_GALAXIAS_100KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.AVANCADA_120KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.AVANCADA_120KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.AVANCADA_120KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.SUPERACAO_150KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.SUPERACAO_150KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.SUPERACAO_150KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.SUPERACAO_II_160KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.SUPERACAO_II_160KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.SUPERACAO_II_160KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.CONQUISTA_180KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.CONQUISTA_180KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.CONQUISTA_180KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.SEM_LIMITES_200KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.SEM_LIMITES_200KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.SEM_LIMITES_200KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.BONITO_250KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.BONITO_250KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.BONITO_250KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      },
      {
      DISTANCIA: CategoriaCaminhadaCorridaTipoEnum.AVANTE_SEMPRE_300KM.distance,
      DESCRICAO: CategoriaCaminhadaCorridaTipoEnum.AVANTE_SEMPRE_300KM.description,
      CHAVE: CategoriaCaminhadaCorridaTipoEnum.AVANTE_SEMPRE_300KM.key,
      SITUACAO: true,
      CRIADO_EM: new Date(),
      ATUALIZADO_EM: new Date(),
      }
    ]);
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.bulkDelete('CATEGORIA_CAMINHADA_CORRIDA', null, {});
  },
};
