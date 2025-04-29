'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('USUARIOS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      ID_PERFIL_TIPO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'PERFIS_TIPO', // Name of the table being referenced
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      ID_SEXO_TIPO: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'SEXO_TIPO',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      ID_ESTADO_CIVIL_TIPO: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'ESTADOS_CIVIS_TIPO',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      ID_ENDERECO: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'ENDERECOS',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      ID_GRUPO_EVENTO: {
        type: Sequelize.INTEGER,
        references: {
          model: 'GRUPOS_EVENTO',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      MATRICULA: {
        type: Sequelize.STRING(36),
        allowNull: true
      },
      NOME: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      EMAIL: {
        type: Sequelize.STRING(255),
        allowNull: false,
        unique: true
      },
      SENHA: {
        type: Sequelize.STRING(255),
        allowNull: true // Nullable for OAuth users
      },
      FOTO_PERFIL: {
        type: Sequelize.STRING,
        allowNull: true
      },
      CPF: {
        type: Sequelize.STRING(11),
        allowNull: true,
        unique: true
      },
      RG: {
        type: Sequelize.STRING(14),
        allowNull: true
      },
      CELULAR: {
        type: Sequelize.STRING(14),
        allowNull: true
      },
      DATA_NASCIMENTO: {
        type: Sequelize.DATE,
        allowNull: true
      },
      PROBLEMA_SAUDE: {
        type: Sequelize.STRING(255),
        allowNull: true
      },
      ATIVIDADE_FISICA_REGULAR: {
        type: Sequelize.STRING(500),
        allowNull: true
      },
      APLICATIVO_ATIVIDADES: {
        type: Sequelize.STRING(100),
        allowNull: true
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      TOKEN_RECUPERAR_SENHA: {
        type: Sequelize.STRING(255),
        allowNull: true
      },
      EXPIRAR_TOKEN_RECUPERAR_SENHA: {
        type: Sequelize.DATE,
        allowNull: true
      },
      CRIADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
      },
      ATUALIZADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('USUARIOS');
  }
};