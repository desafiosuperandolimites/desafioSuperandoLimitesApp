// controllers/opcoesCampoController.js

const OpcoesCampo = require('../models/opcoesCampoModel');
const CamposPersonalizados = require('../models/camposPersonalizadosModel');

// adicionarOpcao
exports.adicionarOpcao = async (req, res) => {
  try {
    const { ID_CAMPOS_PERSONALIZADOS, OPCAO } = req.body;

    // Validate foreign key
    const campoPersonalizado = await CamposPersonalizados.findByPk(ID_CAMPOS_PERSONALIZADOS);
    if (!campoPersonalizado) {
      return res.status(404).json({ error: 'Campo personalizado não encontrado.' });
    }

    const novaOpcao = await OpcoesCampo.create({
      ID_CAMPOS_PERSONALIZADOS,
      OPCAO,
    });

    res.status(201).json(novaOpcao);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// editarOpcao
exports.editarOpcao = async (req, res) => {
  try {
    const opcao = await OpcoesCampo.findByPk(req.params.id);
    if (!opcao) {
      return res.status(404).json({ error: 'Opção não encontrada.' });
    }

    const { ID_CAMPOS_PERSONALIZADOS } = req.body;

    // Validate foreign key if it's being updated
    if (ID_CAMPOS_PERSONALIZADOS) {
      const campoPersonalizado = await CamposPersonalizados.findByPk(ID_CAMPOS_PERSONALIZADOS);
      if (!campoPersonalizado) {
        return res.status(404).json({ error: 'Campo personalizado não encontrado.' });
      }
    }

    await opcao.update(req.body);
    res.status(200).json(opcao);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// removerOpcao
exports.removerOpcao = async (req, res) => {
  try {
    const opcao = await OpcoesCampo.findByPk(req.params.id);
    if (!opcao) {
      return res.status(404).json({ error: 'Opção não encontrada.' });
    }

    await opcao.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// listarOpcoes
exports.listarOpcoes = async (req, res) => {
  try {
    const { idCamposPersonalizados } = req.query;

    const whereClause = {};
    if (idCamposPersonalizados) {
      whereClause.ID_CAMPOS_PERSONALIZADOS = idCamposPersonalizados;
    }

    const opcoes = await OpcoesCampo.findAll({
      where: whereClause,
      include: [
        {
          model: CamposPersonalizados,
          attributes: ['ID', 'NOME_CAMPO'],
        },
      ],
    });
    res.status(200).json(opcoes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// visualizarOpcao
exports.visualizarOpcao = async (req, res) => {
  try {
    const opcao = await OpcoesCampo.findByPk(req.params.id, {
      include: [
        {
          model: CamposPersonalizados,
          attributes: ['ID', 'NOME_CAMPO'],
        },
      ],
    });
    if (!opcao) {
      return res.status(404).json({ error: 'Opção não encontrada.' });
    }
    res.status(200).json(opcao);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
