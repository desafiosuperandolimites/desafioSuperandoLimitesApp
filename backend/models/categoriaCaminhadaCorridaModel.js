const { DataTypes } = require('sequelize');
const db = require('../database/db');

const CategoriaCaminhadaCorrida = db.define('CategoriaCaminhadaCorrida', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    DISTANCIA: {
        type: DataTypes.STRING,
        allowNull: false,
        primaryKey: true
    },
    CHAVE: {
        type: DataTypes.STRING,
        allowNull: false
    },
    DESCRICAO: {
        type: DataTypes.STRING,
        allowNull: false
    },
    SITUACAO: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    CRIADO_EM: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW
    },
    ATUALIZADO_EM: {
        type: DataTypes.DATE,
        allowNull: true,
        defaultValue: DataTypes.NOW
    }
}, {
    tableName: 'CATEGORIA_CAMINHADA_CORRIDA',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM'
});

module.exports = CategoriaCaminhadaCorrida;
