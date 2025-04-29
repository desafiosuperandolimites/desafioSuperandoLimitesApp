'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('EVENTOS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true
      },
      ID_MODALIDADE_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'MODALIDADES_EVENTOS', // Assuming the table name for ModalidadeEvento
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      ID_GRUPO_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'GRUPOS_EVENTO', // Assuming the table name for GrupoEvento
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      ID_DURACAO_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'DURACOES_EVENTO_TIPO', // Assuming the table name for DuracaoEvento
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      ID_PREMIACAO_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'PREMIACOES_EVENTO', // Assuming the table name for PremiacaoEvento
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      ID_USUARIO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'USUARIOS', // Assuming the table name for Usuario
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      NOME: {
        type: Sequelize.STRING(100),
        allowNull: false
      },
      DESCRICAO: {
        type: Sequelize.STRING(500),
        allowNull: true
      },
      LOCAL: {
        type: Sequelize.STRING(500),
        allowNull: true
      },
      CAPA_EVENTO: {
        type: Sequelize.STRING(100), // Store file path or URL
        allowNull: true
      },
      DATA_DESAFIO: {
        type: Sequelize.STRING(100),
        allowNull: true
      },
      SITUACAO: {
        type: Sequelize.BOOLEAN,
        defaultValue: true
      },
      CRIADO_EM: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP')
      },
      ATUALIZADO_EM: {
        type: Sequelize.DATE,
        allowNull: true
      }
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('EVENTOS');
  }
};
