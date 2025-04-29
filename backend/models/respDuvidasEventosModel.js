const { DataTypes } = require('sequelize');
const db = require('../database/db');
const Usuario = require('./usuarioModel'); // Adjust the path if necessary
const DuvidasEventos = require('./duvidasEventosModel'); // Adjust the path if necessary

const RespDuvidasEventos = db.define(
  'RespDuvidasEventos',
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
    ID_DUVIDA_EVENTO: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: DuvidasEventos,
        key: 'ID',
      },
    },
    RESPOSTA: {
      type: DataTypes.STRING(500),
      allowNull: false,
    },
  },
  {
    tableName: 'RESP_DUVIDAS_EVENTOS',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM',
  }
);

// Associations
RespDuvidasEventos.belongsTo(Usuario, { foreignKey: 'ID_USUARIO' });
RespDuvidasEventos.belongsTo(DuvidasEventos, { foreignKey: 'ID_DUVIDA_EVENTO' });

module.exports = RespDuvidasEventos;
