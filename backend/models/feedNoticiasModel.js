const { DataTypes } = require('sequelize');
const sequelize = require('../database/db');


const FeedNoticias = sequelize.define('FeedNoticias', {
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
    CATEGORIA: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    TITULO: {
        type: DataTypes.STRING(100),
        allowNull: false,
    },
    DESCRICAO: {
        type: DataTypes.STRING(200),
        allowNull: false,
    },
    FOTO_CAPA: {
        type: DataTypes.STRING,
        allowNull: true,
    },
    // NOVO CAMPO PARA TOKEN DE COMPARTILHAMENTO
    SHARE_TOKEN: {
        type: DataTypes.STRING,
        allowNull: true, // pode ser preenchido quando a notícia for criada ou durante o fluxo de compartilhamento
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
    },
}, {
    tableName: 'FEED_NOTICIAS',
    timestamps: false,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM'
});

module.exports = FeedNoticias;
