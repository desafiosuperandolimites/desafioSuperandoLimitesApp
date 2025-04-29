const GruposEvento = require('../models/gruposEventoModel');

exports.adicionarGrupoEvento = async (req, res) => {
  try {
    const { NOME, CNPJ, QTD_USUARIOS, SITUACAO } = req.body;

    const novoGrupo = await GruposEvento.create({
      NOME,
      CNPJ,
      QTD_USUARIOS,
      SITUACAO
    });

    res.status(201).json(novoGrupo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};


exports.editarGrupoEvento = async (req, res) => {
  try {
    const grupo = await GruposEvento.findByPk(req.params.id);
    if (!grupo) {
      return res.status(404).json({ error: 'Grupo de evento não encontrado.' });
    }

    await grupo.update(req.body);
    res.status(200).json(grupo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};


exports.removerGrupoEvento = async (req, res) => {
  try {
    const grupo = await GruposEvento.findByPk(req.params.id);
    if (!grupo) {
      return res.status(404).json({ error: 'Grupo de evento não encontrado.' });
    }

    await grupo.destroy();
    return res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.listarGrupoEvento = async (req, res) => {
  try {
    const grupos = await GruposEvento.findAll();
    res.status(200).json(grupos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
exports.visualizarDadosGrupo = async (req, res) => {
  try {
    const { id } = req.params;
    const grupo = await GruposEvento.findByPk(id);
    if (!grupo) {
      return res.status(404).json({ error: 'Grupo não encontrado.' });
    }
    res.status(200).json(grupo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
exports.ativarDesativarGrupo = async (req, res) => {
  try {
    const grupo = await GruposEvento.findByPk(req.params.id);
    if (!grupo) {
      return res.status(404).json({ error: 'Grupo não encontrado.' });
    }

    grupo.SITUACAO = !grupo.SITUACAO; // Toggle the status
    await grupo.save();

    res.status(200).json({ message: `Grupo ${grupo.SITUACAO ? 'ativado' : 'inativado'} com sucesso.`, grupo });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};