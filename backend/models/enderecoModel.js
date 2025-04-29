const { DataTypes } = require('sequelize');
const db = require('../database/db');

const Endereco = db.define('Endereco', {
  ID: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  CEP: {
    type: DataTypes.STRING(8), // Validated as 8-digit string
    allowNull: false,
    validate: {
      is: /^\d{8}$/  // Ensures the CEP is exactly 8 digits
    }
  },
  UF: {
    type: DataTypes.STRING(2), // State abbreviation (2 letters)
    allowNull: false
  },
  CIDADE: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  LOGRADOURO: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  COMPLEMENTO: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  BAIRRO: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  NUMERO: {
    type: DataTypes.INTEGER,
    allowNull: true
  }
}, {
  tableName: 'ENDERECOS',
  timestamps: true, // Automatically adds `CRIADO_EM` and `ATUALIZADO_EM` fields
  createdAt: 'CRIADO_EM',
  updatedAt: 'ATUALIZADO_EM'
});

module.exports = Endereco;