const EstadosCivisTipo = require('../models/estadosCivisTipoModel');
const EstadoCivilEnum = require('../enums/estadoCivilEnum');

exports.createEstadosCivisTipo = async (req, res) => {
  try {
    const { DESCRICAO, CHAVE, SITUACAO } = req.body;
    if (!Object.values(EstadoCivilEnum).some(e => e.key === CHAVE)) {
      return res.status(400).json({ error: 'Este não é um valor válido para tipo de estado civil, escolha algumas das chaves possíveis: ' + Object.keys(EstadoCivilEnum)});
    }
    const estadosCivisTipo = await EstadosCivisTipo.create({
      DESCRICAO,
      CHAVE,
      SITUACAO
    });
    res.status(201).json(estadosCivisTipo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getEstadosCivisTipos = async (req, res) => {
  try {
    const estadosCivisTipo = await EstadosCivisTipo.findAll();
    res.status(200).json(estadosCivisTipo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};