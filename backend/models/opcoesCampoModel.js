const { DataTypes } = require('sequelize');
const db = require('../database/db');
const CamposPersonalizados = require('./camposPersonalizadosModel');

const OpcoesCampo = db.define(
  'OpcoesCampo',
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
    OPCAO: {
      type: DataTypes.STRING,
      allowNull: false,
    },
  },
  {
    tableName: 'OPCOES_CAMPO',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM',
  }
);

// Associations
OpcoesCampo.belongsTo(CamposPersonalizados, { foreignKey: 'ID_CAMPOS_PERSONALIZADOS' });
CamposPersonalizados.hasMany(OpcoesCampo, { foreignKey: 'ID_CAMPOS_PERSONALIZADOS' });

module.exports = OpcoesCampo;
