const Depoimentos = require('../models/depoimentosModel');
const Usuario = require('../models/usuarioModel');

// criarDepoimento
exports.criarDepoimento = async (req, res) => {
  try {
    const { ID_USUARIO, LINK, SITUACAO } = req.body;

    // Validate foreign key
    const usuario = await Usuario.findByPk(ID_USUARIO);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuário não encontrado.' });
    }

    const novoDepoimento = await Depoimentos.create({
      ID_USUARIO,
      LINK,
      SITUACAO,
    });

    res.status(201).json(novoDepoimento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// editarDepoimento
exports.editarDepoimento = async (req, res) => {
  try {
    const depoimento = await Depoimentos.findByPk(req.params.id);
    if (!depoimento) {
      return res.status(404).json({ error: 'Depoimento não encontrado.' });
    }

    const { ID_USUARIO } = req.body;

    // Validate foreign key if being updated
    if (ID_USUARIO) {
      const usuario = await Usuario.findByPk(ID_USUARIO);
      if (!usuario) {
        return res.status(404).json({ error: 'Usuário não encontrado.' });
      }
    }

    await depoimento.update(req.body);
    res.status(200).json(depoimento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// visualizarDepoimento
exports.visualizarDepoimento = async (req, res) => {
  try {
    const depoimento = await Depoimentos.findByPk(req.params.id, {
      include: [
        {
          model: Usuario,
          attributes: ['ID', 'NOME'], // Adjust attributes as per your Usuario model
        },
      ],
    });
    if (!depoimento) {
      return res.status(404).json({ error: 'Depoimento não encontrado.' });
    }
    res.status(200).json(depoimento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// deletarDepoimento
exports.deletarDepoimento = async (req, res) => {
  try {
    const depoimento = await Depoimentos.findByPk(req.params.id);
    if (!depoimento) {
      return res.status(404).json({ error: 'Depoimento não encontrado.' });
    }

    await depoimento.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// listarDepoimentos
exports.listarDepoimentos = async (req, res) => {
  try {
    const { idUsuario } = req.query;

    const whereClause = {};
    if (idUsuario) {
      whereClause.ID_USUARIO = idUsuario;
    }

    const depoimentos = await Depoimentos.findAll({
      where: whereClause,
      include: [
        {
          model: Usuario,
          attributes: ['ID', 'NOME'],
        },
      ],
    });
    res.status(200).json(depoimentos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ativarDesativarDepoimento
exports.ativarDesativarDepoimento = async (req, res) => {
  try {
    const depoimento = await Depoimentos.findByPk(req.params.id);
    if (!depoimento) {
      return res.status(404).json({ error: 'Depoimento não encontrado.' });
    }

    depoimento.SITUACAO = !depoimento.SITUACAO;
    await depoimento.save();

    res.status(200).json({
      message: `Depoimento ${depoimento.SITUACAO ? 'ativado' : 'desativado'} com sucesso.`,
      depoimento,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
