const { DataTypes } = require('sequelize');
const sequelize = require('../database/db');
const Usuario = require('./usuarioModel');
const InscricaoEvento = require('./inscricaoEventoModel');
const DadosBancariosAdm = require('./dadosBancariosAdmModel');
const status_pagamento = require('./statusPagamentoModel');


const PagamentosInscricoes = sequelize.define('PagamentosInscricoes', {
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
    ID_INSCRICAO_EVENTO: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: InscricaoEvento,
            key: 'ID'
        }
    },
    ID_DADOS_BANCARIOS_ADM: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
            model: DadosBancariosAdm,
            key: 'ID'
        }
    },
    ID_STATUS_PAGAMENTO: {
        type: DataTypes.INTEGER,
        allowNull: false,
        references: {
            model: status_pagamento,
            key: 'ID'
        }
    },
    COMPROVANTE: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    DATA_PAGAMENTO: {
        type: DataTypes.DATE,
        allowNull: false,
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
    MOTIVO: {
        type: DataTypes.STRING,
        allowNull: true,
    },
}, {
    tableName: 'PAGAMENTOS_INSCRICOES',
    timestamps: false,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM'
});

module.exports = PagamentosInscricoes;
