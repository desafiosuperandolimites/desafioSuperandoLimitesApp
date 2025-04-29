const { DataTypes } = require('sequelize');
const db = require('../database/db');
const Usuario = require('./usuarioModel'); // Adjust the path if necessary

const Depoimentos = db.define(
  'Depoimentos',
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
    LINK: {
      type: DataTypes.STRING,
      allowNull: true,
    },
    SITUACAO: {
      type: DataTypes.BOOLEAN,
      defaultValue: true,
    },
  },
  {
    tableName: 'DEPOIMENTOS',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM',
  }
);

// Associations
Depoimentos.belongsTo(Usuario, { foreignKey: 'ID_USUARIO' });
Usuario.hasMany(Depoimentos, { foreignKey: 'ID_USUARIO' });

module.exports = Depoimentos;
