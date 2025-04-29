const PerfisTipo = require('../models/perfisTipoModel');
const PerfisTipoEnum = require('../enums/perfisTipoEnum');

exports.createPerfisTipo = async (req, res) => {
  try {
    const { DESCRICAO, CHAVE, SITUACAO } = req.body;
    if (!Object.values(PerfisTipoEnum).some(e => e.key === CHAVE)) {
      return res.status(400).json({ error: 'Este não é um valor válido para tipo de estado civil, escolha algumas das chaves possíveis: ' + Object.keys(PerfisTipoEnum)});
    }
    const perfisTipo = await PerfisTipo.create({
      DESCRICAO,
      CHAVE,
      SITUACAO
    });
    res.status(201).json(perfisTipo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getPerfisTipos = async (req, res) => {
  try {
    const perfisTipos = await PerfisTipo.findAll();
    res.status(200).json(perfisTipos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};