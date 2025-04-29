const { DataTypes } = require('sequelize');
const db = require('../database/db');

const DadosEstatisticosUsuarios = db.define(
    'DadosEstatisticosUsuarios',
    {
        ID: {
            type: DataTypes.INTEGER,
            primaryKey: true,
            autoIncrement: true,
        },
        ID_USUARIO_INSCRITO: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'USUARIOS',
                key: 'ID',
            },
        },
        ID_USUARIO_CADASTRA: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'USUARIOS',
                key: 'ID',
            },
        },
        ID_USUARIO_APROVA: {
            type: DataTypes.INTEGER,
            allowNull: true,
            references: {
                model: 'USUARIOS',
                key: 'ID',
            },
        },
        ID_EVENTO: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'EVENTOS',
                key: 'ID',
            },
        },
        ID_STATUS_DADOS_ESTATISTICOS: {
            type: DataTypes.INTEGER,
            allowNull: false,
            references: {
                model: 'STATUS_DADOS_ESTATISTICOS',
                key: 'ID',
            },
        },
        KM_PERCORRIDO: {
            type: DataTypes.DOUBLE,
            allowNull: false,
        },
        FOTO: {
            type: DataTypes.STRING,
            allowNull: true,
        },
        DATA_ATIVIDADE: {
            type: DataTypes.DATE,
            allowNull: false,
        },
        SEMANA: {
            type: DataTypes.INTEGER,
            allowNull: true,
        },
        OBSERVACAO: {
            type: DataTypes.STRING(500),
            allowNull: true,
        },
    },
    {
        tableName: 'DADOS_ESTATISTICOS_USUARIOS',
        timestamps: true,
        createdAt: 'CRIADO_EM',
        updatedAt: 'ATUALIZADO_EM',
    }
);

module.exports = DadosEstatisticosUsuarios;
