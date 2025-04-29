const { DataTypes } = require('sequelize');
const db = require('../database/db');

const DadosBancariosAdm = db.define('DadosBancariosAdm', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    ID_USUARIO: {
        type: DataTypes.INTEGER,
        allowNull: false
    },
    AGENCIA: {
        type: DataTypes.STRING(500),
        allowNull: false
    },
    CONTA: {
        type: DataTypes.STRING(500),
        allowNull: false
    },
    TITULAR: {
        type: DataTypes.STRING(500),
        allowNull: false
    },
    BANCO: {
        type: DataTypes.STRING(500),
        allowNull: false
    },
    PIX: {
        type: DataTypes.STRING,
        allowNull: true
    },
    DATA_PAGAMENTO: {
        type: DataTypes.DATE,
        allowNull: true
    },
    DATA_ATUALIZACAO: {
        type: DataTypes.DATE,
        allowNull: true
    }
}, {
    tableName: 'DADOS_BANCARIOS_ADM',
    timestamps: false
});

module.exports = DadosBancariosAdm;
