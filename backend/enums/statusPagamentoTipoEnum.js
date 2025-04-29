const StatusPagamentoEnum = {
    NAO_PAGO: { key: 'NAO_PAGO', description: 'Não pago' },
    PAGO: { key: 'PAGO', description: 'Pago' },
    REVISAR_COMPROVANTE: { key: 'REVISAR_COMPROVANTE', description: 'Revisar comprovante' },
    CANCELADO: { key: 'CANCELADO', description: 'Cancelado' },
    ISENTO: { key: 'ISENTO', description: 'Isento' }
};

module.exports = StatusPagamentoEnum;
