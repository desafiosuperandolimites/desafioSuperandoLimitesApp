const { DataTypes } = require('sequelize');
const db = require('../database/db');

const PremiacoeEvento = db.define('PremiacoesEvento', {
  ID: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  NOME: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  DESCRICAO: {
    type: DataTypes.STRING(255),
    allowNull: true
  },

  SITUACAO: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'PREMIACOES_EVENTO',
  timestamps: true,
  createdAt: 'CRIADO_EM',
  updatedAt: 'ATUALIZADO_EM'
});

module.exports = PremiacoeEvento;
