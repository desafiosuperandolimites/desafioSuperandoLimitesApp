const { DataTypes } = require('sequelize');
const db = require('../database/db');

const EstadosCivisTipo = db.define('EstadosCivisTipo', {
  ID: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  DESCRICAO: {
    type: DataTypes.STRING(250),
    allowNull: false
  },
  CHAVE: {
    type: DataTypes.STRING(3),
    allowNull: false
  },
  SITUACAO: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'ESTADOS_CIVIS_TIPO',
  timestamps: true, // Adds createdAt and updatedAt automatically
  createdAt: 'CRIADO_EM',
  updatedAt: 'ATUALIZADO_EM'
});

module.exports = EstadosCivisTipo;