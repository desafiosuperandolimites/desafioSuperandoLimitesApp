'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('PAGAMENTOS_INSCRICOES', {
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
      ID_INSCRICAO_EVENTO: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'INSCRICOES_EVENTOS',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      ID_DADOS_BANCARIOS_ADM: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'DADOS_BANCARIOS_ADM',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL'
      },
      ID_STATUS_PAGAMENTO: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: {
          model: 'STATUS_PAGAMENTO',
          key: 'ID'
        },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT'
      },
      COMPROVANTE: {
        type: Sequelize.STRING,
        allowNull: true
      },
      DATA_PAGAMENTO: {
        allowNull: true,
        type: Sequelize.DATE,
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
    await queryInterface.dropTable('PAGAMENTOS_INSCRICOES');
  }
};
