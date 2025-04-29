const StatusInscricaoEnum = {
    PENDENTE_PAGAMENTO: { key: 'PENDENTE_PAGAMENTO', description: 'Pendente de Pagamento' },
    PENDENTE_APROVACAO: { key: 'PENDENTE_APROVACAO', description: 'Pendente de Aprovação' },
    PAGA: { key: 'PAGA', description: 'Paga' },
    AGUARDANDO_REVISAO: { key: 'AGUARDANDO_REVISAO', description: 'Aguardando revisão' },
    CANCELADO: { key: 'CANCELADO', description: 'Cancelado' },
    MOVIDO_GRUPO: { key: 'MOVIDO_GRUPO', description: 'Movido do grupo' },
    ISENTA: { key: 'ISENTA', description: 'Isenta' }
};

module.exports = StatusInscricaoEnum;
