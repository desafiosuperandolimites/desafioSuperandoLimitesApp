const TipoCampo = require('../models/tipoCampo');

exports.listarTiposCampo = async (req, res) => {
    try {
        const grupos = await TipoCampo.findAll();
        res.status(200).json(grupos);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};