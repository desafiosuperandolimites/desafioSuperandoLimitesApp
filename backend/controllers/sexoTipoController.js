// backend/controllers/sexoTipoController.js

const SexoTipo= require('../models/sexoTipoModel');
const SexoTipoEnum = require('../enums/sexoTipoEnum');

exports.createSexoTipo = async (req, res) => {
  try {
    const { DESCRICAO, CHAVE, SITUACAO } = req.body;
    if (!Object.values(SexoTipoEnum).some(e => e.key === CHAVE)) {
      return res.status(400).json({ error: 'Este não é um valor válido para tipo de sexo, escolha algumas das chaves possíveis: ' + Object.keys(SexoTipoEnum)});
    }
    const sexoTipo = await SexoTipo.create({
      DESCRICAO,
      CHAVE,
      SITUACAO
    });
    res.status(201).json(sexoTipo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.getSexoTipos = async (req, res) => {
  try {
    const sexoTipos = await SexoTipo.findAll();
    res.status(200).json(sexoTipos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
