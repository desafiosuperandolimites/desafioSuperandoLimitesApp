'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('DADOS_ESTATISTICOS_USUARIOS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      ID_USUARIO_INSCRITO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'USUARIOS',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      ID_USUARIO_CADASTRA: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'USUARIOS',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      ID_USUARIO_APROVA: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'USUARIOS',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      ID_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'EVENTOS',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      ID_STATUS_DADOS_ESTATISTICOS: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'STATUS_DADOS_ESTATISTICOS',
          key: 'ID',
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      KM_PERCORRIDO: {
        type: Sequelize.DOUBLE,
        allowNull: false,
      },
      FOTO: {
        type: Sequelize.STRING,
        allowNull: true,
      },
      DATA_ATIVIDADE: {
        type: Sequelize.DATE,
        allowNull: false,
      },
      SEMANA: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      OBSERVACAO: {
        type: Sequelize.STRING(500),
        allowNull: true,
      },
      CRIADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
      ATUALIZADO_EM: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.NOW,
      },
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('DADOS_ESTATISTICOS_USUARIOS');
  },
};
