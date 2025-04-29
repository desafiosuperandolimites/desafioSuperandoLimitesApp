const StatusPagamento = require('../models/statusPagamentoModel');

exports.listarStatusPagamento = async (req, res) => {
    try {
        const statusList = await StatusPagamento.findAll();
        res.status(200).json(statusList);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
