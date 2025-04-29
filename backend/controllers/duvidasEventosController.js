const DuvidasEventos = require('../models/duvidasEventosModel');
const Usuario = require('../models/usuarioModel');

// adicionarDuvida
exports.adicionarDuvida = async (req, res) => {
  try {
    const { ID_USUARIO, DUVIDA, SITUACAO } = req.body;

    // Validate foreign key
    const usuario = await Usuario.findByPk(ID_USUARIO);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuário não encontrado.' });
    }

    const novaDuvida = await DuvidasEventos.create({
      ID_USUARIO,
      DUVIDA,
      SITUACAO,
    });

    res.status(201).json(novaDuvida);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// editarDuvida
exports.editarDuvida = async (req, res) => {
  try {
    const duvida = await DuvidasEventos.findByPk(req.params.id);
    if (!duvida) {
      return res.status(404).json({ error: 'Dúvida não encontrada.' });
    }

    const { ID_USUARIO } = req.body;

    // Validate foreign key if being updated
    if (ID_USUARIO) {
      const usuario = await Usuario.findByPk(ID_USUARIO);
      if (!usuario) {
        return res.status(404).json({ error: 'Usuário não encontrado.' });
      }
    }

    await duvida.update(req.body);
    res.status(200).json(duvida);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ativarDesativarDuvida
exports.ativarDesativarDuvida = async (req, res) => {
  try {
    const duvida = await DuvidasEventos.findByPk(req.params.id);
    if (!duvida) {
      return res.status(404).json({ error: 'Dúvida não encontrada.' });
    }

    duvida.SITUACAO = !duvida.SITUACAO;
    await duvida.save();

    res.status(200).json({
      message: `Dúvida ${duvida.SITUACAO ? 'ativada' : 'desativada'} com sucesso.`,
      duvida,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// removerDuvida
exports.removerDuvida = async (req, res) => {
  try {
    const duvida = await DuvidasEventos.findByPk(req.params.id);
    if (!duvida) {
      return res.status(404).json({ error: 'Dúvida não encontrada.' });
    }

    await duvida.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// listarDuvida
exports.listarDuvida = async (req, res) => {
  try {
    const { idUsuario } = req.query;

    const whereClause = {};
    if (idUsuario) {
      whereClause.ID_USUARIO = idUsuario;
    }

    const duvidas = await DuvidasEventos.findAll({
      include: [
        {
          model: Usuario,
          attributes: ['ID', 'NOME'],
        },
      ],
    });
    res.status(200).json(duvidas);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// visualizarDuvida
exports.visualizarDuvida = async (req, res) => {
  try {
    const duvida = await DuvidasEventos.findByPk(req.params.id, {
      include: [
        {
          model: Usuario,
          attributes: ['ID', 'NOME'], // Adjust attributes as per your Usuario model
        },
      ],
    });
    if (!duvida) {
      return res.status(404).json({ error: 'Dúvida não encontrada.' });
    }
    res.status(200).json(duvida);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
