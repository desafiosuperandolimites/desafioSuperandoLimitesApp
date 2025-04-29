const { DataTypes } = require('sequelize');
const db = require('../database/db');
const ModalidadeEvento = require('./modalidadeModel'); // Modelo de modalidades de eventos
const GrupoEvento = require('./gruposEventoModel'); // Modelo de grupos de eventos
const DuracaoEvento = require('./duracaoEventoModel'); // Modelo de duração do evento
const PremiacaoEvento = require('./premiacaoModel'); // Modelo de premiação do evento
const Usuario = require('./usuarioModel'); // Modelo de usuário

const Evento = db.define('Evento', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    ID_MODALIDADE_EVENTO: {
        type: DataTypes.INTEGER,
        references: {
            model: ModalidadeEvento,
            key: 'ID'
        },
        allowNull: false
    },
    ID_GRUPO_EVENTO: {
        type: DataTypes.INTEGER,
        references: {
            model: GrupoEvento,
            key: 'ID'
        },
        allowNull: false
    },
    ID_PREMIACAO_EVENTO: {
        type: DataTypes.INTEGER,
        references: {
            model: PremiacaoEvento,
            key: 'ID'
        },
        allowNull: false
    },
    ID_USUARIO: {
        type: DataTypes.INTEGER,
        references: {
            model: Usuario,
            key: 'ID'
        },
        allowNull: false
    },
    NOME: {
        type: DataTypes.STRING(100),
        allowNull: false
    },
    DESCRICAO: {
        type: DataTypes.STRING(500),
        allowNull: true
    },
    LOCAL: {
        type: DataTypes.STRING(500),
        allowNull: true
    },
    CAPA_EVENTO: {
        type: DataTypes.STRING(100), // Armazenar caminho do arquivo ou URL
        allowNull: true
    },
    DATA_INICIO_DESAFIO: {
        type: DataTypes.STRING(100),
        allowNull: true
    },
    DATA_FIM_DESAFIO: {
        type: DataTypes.STRING(100),
        allowNull: true
    },
    ISENTO_PAGAMENTO: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    DATA_INICIO_INSCRICAO: {
        type: DataTypes.STRING(100),
        allowNull: true
    },
    DATA_FIM_INSCRICAO: {
        type: DataTypes.STRING(100),
        allowNull: true
    },
    VALOR_EVENTO: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: true
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
        allowNull: true,
        defaultValue: DataTypes.NOW
    }
}, {
    tableName: 'EVENTOS',
    timestamps: true, // Sequelize automaticamente preenche os campos de data de criação e atualização
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM'
});

module.exports = Evento;
