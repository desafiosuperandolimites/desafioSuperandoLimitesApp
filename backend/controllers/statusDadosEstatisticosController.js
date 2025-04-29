const StatusDadosEstatisticos = require('../models/statusDadosEstatisticos');

exports.listarStatusDadosEstatisticos = async (req, res) => {
    try {
        const statusList = await StatusDadosEstatisticos.findAll();
        res.status(200).json(statusList);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
