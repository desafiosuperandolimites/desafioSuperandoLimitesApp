const { DataTypes } = require('sequelize');
const db = require('../database/db');

const DuracoesEventoTipo = db.define('DuracoesEventoTipo', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    DESCRICAO: {
        type: DataTypes.STRING(250),
        allowNull: false
    },
    CHAVE_NOME: {
        type: DataTypes.STRING(150),
        allowNull: false,
        unique: true // Assuming that the CHAVE/NOME should be unique
    },
    SITUACAO: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true // Assuming default active state
    },
    DATA_CRIACAO: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW
    },
    DATA_ATUALIZACAO: {
        type: DataTypes.DATE,
        allowNull: true
    }
}, {
    tableName: 'DURACOES_EVENTO_TIPO',
    timestamps: false, // Set to false if these fields are managed manually
    createdAt: 'DATA_CRIACAO', // Custom field mapping
    updatedAt: 'DATA_ATUALIZACAO' // Custom field mapping
});

module.exports = DuracoesEventoTipo;
