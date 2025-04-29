const { DataTypes } = require('sequelize');
const db = require('../database/db');
const Usuario = require('./usuarioModel'); // Adjust the path if necessary

const DuvidasEventos = db.define(
  'DuvidasEventos',
  {
    ID: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    ID_USUARIO: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Usuario,
        key: 'ID',
      },
    },
    DUVIDA: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
    SITUACAO: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
  },
  {
    tableName: 'DUVIDAS_EVENTOS',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM',
  }
);

// Associations
DuvidasEventos.belongsTo(Usuario, { foreignKey: 'ID_USUARIO' });

module.exports = DuvidasEventos;
