// models/respCamposPersonalizadosEventoModel.js

const { DataTypes } = require('sequelize');
const db = require('../database/db');
const CamposPersonalizados = require('./camposPersonalizadosModel');
const Usuario = require('./usuarioModel');

const RespCamposPersonalizadosEvento = db.define(
  'RespCamposPersonalizadosEvento',
  {
    ID: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    ID_CAMPOS_PERSONALIZADOS: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: CamposPersonalizados,
        key: 'ID',
      },
    },
    ID_USUARIO: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: Usuario,
        key: 'ID',
      },
    },
    RESPOSTA_CAMPO: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    tableName: 'RESP_CAMPOS_PERSONALIZADOS_EVENTO',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM',
  }
);

// Associations
RespCamposPersonalizadosEvento.belongsTo(CamposPersonalizados, { foreignKey: 'ID_CAMPOS_PERSONALIZADOS' });
RespCamposPersonalizadosEvento.belongsTo(Usuario, { foreignKey: 'ID_USUARIO' });

module.exports = RespCamposPersonalizadosEvento;
