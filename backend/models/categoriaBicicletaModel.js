const { DataTypes } = require('sequelize');
const db = require('../database/db');

const CategoriaBicicleta = db.define('CategoriaBicicleta', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    DISTANCIA: {
        type: DataTypes.STRING(10),
        allowNull: false
    },
    CHAVE: {
        type: DataTypes.STRING(20),
        allowNull: false
    },
    DESCRICAO: {
        type: DataTypes.STRING(250),
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
        allowNull: false,
        defaultValue: DataTypes.NOW
    }
}, {
    tableName: 'CATEGORIA_BICICLETA',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM'
});

module.exports = CategoriaBicicleta;
