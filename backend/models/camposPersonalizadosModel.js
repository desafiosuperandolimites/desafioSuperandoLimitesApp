// models/camposPersonalizadosModel.js

const { DataTypes } = require('sequelize');
const db = require('../database/db');
const GruposEvento = require('./gruposEventoModel');
const TipoCampo = require('./tipoCampo');

const CamposPersonalizados = db.define(
  'CamposPersonalizados',
  {
    ID: {
      type: DataTypes.INTEGER,
      primaryKey: true,
      autoIncrement: true,
    },
    ID_GRUPOS_EVENTO: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: GruposEvento,
        key: 'ID',
      },
    },
    ID_TIPO_CAMPO: {
      type: DataTypes.INTEGER,
      allowNull: false,
      references: {
        model: TipoCampo,
        key: 'ID',
      },
    },
    NOME_CAMPO: {
      type: DataTypes.STRING(155),
      allowNull: false,
    },
    OBRIGATORIO: {
      type: DataTypes.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    },
    SITUACAO: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
  },
  {
    tableName: 'CAMPOS_PERSONALIZADOS',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM',
  }
);

// Associations
CamposPersonalizados.belongsTo(GruposEvento, { foreignKey: 'ID_GRUPOS_EVENTO' });
CamposPersonalizados.belongsTo(TipoCampo, { foreignKey: 'ID_TIPO_CAMPO' });

module.exports = CamposPersonalizados;
