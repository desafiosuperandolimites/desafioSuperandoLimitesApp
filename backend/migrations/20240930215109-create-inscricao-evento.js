'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('INSCRICOES_EVENTOS', {
      ID: {
        type: Sequelize.INTEGER,
        primaryKey: true,
        autoIncrement: true,
      },
      ID_USUARIO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'USUARIOS',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE'
      },
      ID_CATEGORIA_BICICLETA: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'CATEGORIA_BICICLETA',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      ID_CATEGORIA_CAMINHADA_CORRIDA: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'CATEGORIA_CAMINHADA_CORRIDA',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      ID_STATUS_INSCRICAO_TIPO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'STATUS_INSCRICAO',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      ID_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'EVENTOS',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      META: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      TERMO_CIENTE: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
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
    await queryInterface.dropTable('INSCRICOES_EVENTOS');
  }
};
