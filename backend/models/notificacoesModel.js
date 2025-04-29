const { DataTypes } = require('sequelize');
const sequelize = require('../database/db');


const Notificacoes = sequelize.define('Notificacoes', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false,
    },
    ID_USUARIO: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    TITLE: {
        type: DataTypes.STRING (255),
        allowNull: false,
    },
    BODY: {
        type: DataTypes.TEXT,
        allowNull: false,
    },
    LIDA: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
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
    },
}, {
    tableName: 'NOTIFICACOES',
    timestamps: false,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM'
});

module.exports = Notificacoes;
