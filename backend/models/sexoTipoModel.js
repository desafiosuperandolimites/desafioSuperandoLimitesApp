// models/sexoTipoModel.js

const { DataTypes } = require('sequelize');
const db = require('../database/db');

const SexoTipo = db.define('SexoTipo', {
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
  tableName: 'SEXO_TIPO',
  timestamps: true, // This will automatically add createdAt and updatedAt fields
  createdAt: 'CRIADO_EM',
  updatedAt: 'ATUALIZADO_EM'
});

module.exports = SexoTipo;
