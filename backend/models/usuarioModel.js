const { DataTypes } = require('sequelize');
const db = require('../database/db');
const PerfilTipo = require('./perfisTipoModel');
const SexoTipo = require('./sexoTipoModel');
const EstadoCivilTipo = require('./estadosCivisTipoModel');
const Endereco = require('./enderecoModel');
const GruposEvento = require('./gruposEventoModel');

const Usuario = db.define('Usuario', {
    ID: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true
    },
    ID_PERFIL_TIPO: {
        type: DataTypes.INTEGER,
        references: {
            model: PerfilTipo,
            key: 'ID'
        },
        allowNull: false
    },
    ID_SEXO_TIPO: {
        type: DataTypes.INTEGER,
        references: {
            model: SexoTipo,
            key: 'ID'
        },
        allowNull: true
    },
    ID_ESTADO_CIVIL_TIPO: {
        type: DataTypes.INTEGER,
        references: {
            model: EstadoCivilTipo,
            key: 'ID'
        },
        allowNull: true
    },
    ID_ENDERECO: {
        type: DataTypes.INTEGER,
        references: {
            model: Endereco,
            key: 'ID'
        },
        allowNull: true
    },
    ID_GRUPO_EVENTO: {
        type: DataTypes.INTEGER,
        references: {
            model: GruposEvento,
            key: 'ID'
        },
        allowNull: true
    },
    MATRICULA: {
        type: DataTypes.STRING(36),
        allowNull: true,
    },
    NOME: {
        type: DataTypes.STRING(255),
        allowNull: false
    },
    PROFISSAO: {
        type: DataTypes.STRING(255),
        allowNull: true
    },
    EMAIL: {
        type: DataTypes.STRING(255),
        allowNull: false,
        unique: true,
        validate: {
            isEmail: true
        }
    },
    SENHA: {
        type: DataTypes.STRING(255),
        allowNull: true  // Nullable for OAuth users
    },
    FOTO_PERFIL: {
        type: DataTypes.TEXT, // Store file path or URL
        allowNull: true
    },
    CPF: {
        type: DataTypes.STRING(11),
        allowNull: true,
        unique: true
    },
    CELULAR: {
        type: DataTypes.STRING(14),
        allowNull: true
    },
    DATA_NASCIMENTO: {
        type: DataTypes.DATE,
        allowNull: true
    },
    PROBLEMA_SAUDE: {
        type: DataTypes.STRING(255),
        allowNull: true
    },
    ATIVIDADE_FISICA_REGULAR: {
        type: DataTypes.STRING(500),
        allowNull: true
    },
    APLICATIVO_ATIVIDADES: {
        type: DataTypes.STRING(100),
        allowNull: true
    },
    SITUACAO: {
        type: DataTypes.BOOLEAN,
        defaultValue: true
    },
    PAGAMENTO_PENDENTE: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },
    CADASTRO_PENDENTE: {
        type: DataTypes.BOOLEAN,
        defaultValue: false
    },

    ALTURA: {
        type: DataTypes.DECIMAL(5, 2),
        allowNull: true

    },
    PESO: {
        type: DataTypes.DECIMAL(5, 2),
        allowNull: true

    },
    TOKEN_RECUPERAR_SENHA: {
        type: DataTypes.STRING(255),
        allowNull: true
    },
    EXPIRAR_TOKEN_RECUPERAR_SENHA: {
        type: DataTypes.DATE,
        allowNull: true
    },
    FCM_TOKEN: {
        type: DataTypes.STRING(255),
        allowNull: true,
    },
}, {
    tableName: 'USUARIOS',
    timestamps: true,
    createdAt: 'CRIADO_EM',
    updatedAt: 'ATUALIZADO_EM'
});

module.exports = Usuario;