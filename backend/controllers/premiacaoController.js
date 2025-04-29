const Premiacao = require('../models/premiacaoModel');

exports.adicionarPremiacao = async (req, res) => {
  try {
    const { NOME, DESCRICAO } = req.body;

    const novaPremiacao = await Premiacao.create({
      NOME,
      DESCRICAO,
    });

    res.status(201).json(novaPremiacao);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.editarPremiacao = async (req, res) => {
  try {
    const premiacao = await Premiacao.findByPk(req.params.id);
    if (!premiacao) {
      return res.status(404).json({ error: 'Premiação não encontrada.' });
    }

    await premiacao.update(req.body);
    res.status(200).json(premiacao);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.removerPremiacao = async (req, res) => {
  try {
    const premiacao = await Premiacao.findByPk(req.params.id);
    if (!premiacao) {
      return res.status(404).json({ error: 'Premiação não encontrada.' });
    }

    await premiacao.destroy();
    return res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.listarPremiacao = async (req, res) => {
  try {
    const premiacao = await Premiacao.findAll();
    res.status(200).json(premiacao);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
exports.visualizarDadosPremiacao = async (req, res) => {
  try {
    const { id } = req.params;
    const premiacao = await Premiacao.findByPk(id);
    if (!premiacao) {
      return res.status(404).json({ error: 'Premiacao não encontrado.' });
    }
    res.status(200).json(premiacao);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

