const { DataTypes } = require('sequelize');
const db = require('../database/db');

const StatusPagamento = db.define('StatusPagamento', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
    },
    DESCRICAO: {
        type: DataTypes.STRING(250),
        allowNull: false,
    },
    CHAVENOME: {
        type: DataTypes.STRING(50),
        allowNull: false,
    },
    SITUACAO: {
        type: DataTypes.BOOLEAN,
        defaultValue: true,
    },
}, {
    tableName: 'STATUS_PAGAMENTO',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM',
});

module.exports = StatusPagamento;
