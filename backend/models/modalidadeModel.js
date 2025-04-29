const { DataTypes } = require('sequelize');
const db = require('../database/db');

const ModalidadesEventos = db.define('ModalidadesEventos', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    DESCRICAO: {
        type: DataTypes.STRING(155),
        allowNull: false
    },
    CHAVE_NOME: {
        type: DataTypes.STRING(255),
        allowNull: false,
        unique: true // Assuming uniqueness for this field
    },
    SITUACAO: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true // Assuming default active state
    },
    CRIADO_EM: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW
    },
    ATUALIZADO_EM: {
        type: DataTypes.DATE,
        allowNull: true
    }
}, {
    tableName: 'MODALIDADES_EVENTOS',
    timestamps: false, // Disables automatic timestamp fields as we're handling manually
    createdAt: 'CRIADO_EM', // Custom mapping for createdAt
    updatedAt: 'ATUALIZADO_EM' // Custom mapping for updatedAt
});

module.exports = ModalidadesEventos;
