const { DataTypes } = require('sequelize');
const db = require('../database/db');

const GruposEvento = db.define('GruposEvento', {
  ID: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  NOME: {
    type: DataTypes.STRING(250),
    allowNull: false
  },
  CNPJ: {
    type: DataTypes.STRING(14),
    allowNull: false,
    validate: {
      is: /^\d{14}$/ // Ensures the CNPJ is exactly 14 digits
    }
  },
  QTD_USUARIOS: {
    type: DataTypes.STRING(255),
    allowNull: true // Assuming this field can be nullable
  },
  SITUACAO: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  }
}, {
  tableName: 'GRUPOS_EVENTO',
  timestamps: true, // Automatically adds `CRIADO_EM` and `ATUALIZADO_EM` fields
  createdAt: 'CRIADO_EM',
  updatedAt: 'ATUALIZADO_EM'
});

module.exports = GruposEvento;