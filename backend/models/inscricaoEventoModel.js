const { DataTypes } = require('sequelize');
const sequelize = require('../database/db');
const Usuario = require('./usuarioModel');
const Categoria_bicicleta = require('./categoriaBicicletaModel');
const Categoria_caminhada_corrida = require('./categoriaCaminhadaCorridaModel');
const EVENTO = require('./eventoModel');
const status_inscricao = require('./statusInscricaoModel');
const status_pagamento = require('./statusPagamentoModel');


const InscricaoEvento = sequelize.define('InscricaoEvento', {
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
            key: 'ID'
        }
    },
    ID_CATEGORIA_BICICLETA: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Categoria_bicicleta,
            key: 'ID'
        }
    },
    ID_CATEGORIA_CAMINHADA_CORRIDA: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: Categoria_caminhada_corrida,
            key: 'ID'
        }
    },
    ID_STATUS_INSCRICAO_TIPO: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: status_inscricao,
            key: 'ID'
        }
    },
    ID_EVENTO: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: EVENTO,
            key: 'ID'
        }
    },
    META: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    TERMO_CIENTE: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
    },
    MEDALHA_ENTREGUE: {
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
        allowNull: true
    }
}, {
    tableName: 'INSCRICOES_EVENTOS',
    timestamps: true, // Sequelize automaticamente preenche os campos de data de criação e atualização
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM'
});

module.exports = InscricaoEvento;
