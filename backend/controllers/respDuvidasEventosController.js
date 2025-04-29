const RespDuvidasEventos = require('../models/respDuvidasEventosModel');
const Usuario = require('../models/usuarioModel');
const DuvidasEventos = require('../models/duvidasEventosModel');
const notificationService = require('../services/notificationService');


// adicionarRespostaDuvida
exports.adicionarRespostaDuvida = async (req, res) => {
  try {
    const { ID_USUARIO, ID_DUVIDA_EVENTO, RESPOSTA } = req.body;

    // Validate foreign keys
    const usuario = await Usuario.findByPk(ID_USUARIO);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuário não encontrado.' });
    }

    const duvidaEvento = await DuvidasEventos.findByPk(ID_DUVIDA_EVENTO);
    if (!duvidaEvento) {
      return res.status(404).json({ error: 'Dúvida do evento não encontrada.' });
    }

    const usuarioDuvida = await Usuario.findByPk(duvidaEvento.ID_USUARIO);

    const novaResposta = await RespDuvidasEventos.create({
      ID_USUARIO,
      ID_DUVIDA_EVENTO,
      RESPOSTA,
    });

    // Send push notification to the user
    const title = 'Dúvida Respondida';
    const body = `Sua dúvida acaba de ser respondida. Acesse o app para mais detalhes.`;
    notificationService.sendNotificationToUser(usuarioDuvida.ID, title, body);

    res.status(201).json(novaResposta);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// editarRespostaDuvida
exports.editarRespostaDuvida = async (req, res) => {
  try {
    const resposta = await RespDuvidasEventos.findByPk(req.params.id);
    if (!resposta) {
      return res.status(404).json({ error: 'Resposta não encontrada.' });
    }

    const { ID_USUARIO, ID_DUVIDA_EVENTO } = req.body;

    // Validate foreign keys if being updated
    if (ID_USUARIO) {
      const usuario = await Usuario.findByPk(ID_USUARIO);
      if (!usuario) {
        return res.status(404).json({ error: 'Usuário não encontrado.' });
      }
    }

    if (ID_DUVIDA_EVENTO) {
      const duvidaEvento = await DuvidasEventos.findByPk(ID_DUVIDA_EVENTO);
      if (!duvidaEvento) {
        return res.status(404).json({ error: 'Dúvida do evento não encontrada.' });
      }
    }

    await resposta.update(req.body);
    res.status(200).json(resposta);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// removerRespostaDuvida
exports.removerRespostaDuvida = async (req, res) => {
  try {
    const resposta = await RespDuvidasEventos.findByPk(req.params.id);
    if (!resposta) {
      return res.status(404).json({ error: 'Resposta não encontrada.' });
    }

    await resposta.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// listarRespostasDuvida
exports.listarRespostasDuvida = async (req, res) => {
  try {
    const { idDuvidaEvento } = req.query;

    const whereClause = {};
    if (idDuvidaEvento) {
      whereClause.ID_DUVIDA_EVENTO = idDuvidaEvento;
    }

    const respostas = await RespDuvidasEventos.findAll({
      where: whereClause,
      include: [
        {
          model: Usuario,
          attributes: ['ID', 'NOME'], // Adjust attributes as per your Usuario model
        },
        {
          model: DuvidasEventos,
          attributes: ['ID', 'DUVIDA'],
        },
      ],
    });
    res.status(200).json(respostas);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// visualizarRespostaDuvida
exports.visualizarRespostaDuvida = async (req, res) => {
  try {
    const resposta = await RespDuvidasEventos.findByPk(req.params.id, {
      include: [
        {
          model: Usuario,
          attributes: ['ID', 'NOME'],
        },
        {
          model: DuvidasEventos,
          attributes: ['ID', 'DUVIDA'],
        },
      ],
    });
    if (!resposta) {
      return res.status(404).json({ error: 'Resposta não encontrada.' });
    }
    res.status(200).json(resposta);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
