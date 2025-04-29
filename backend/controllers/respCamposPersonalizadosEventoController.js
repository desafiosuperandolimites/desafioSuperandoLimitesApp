// controllers/respCamposPersonalizadosEventoController.js

const RespCamposPersonalizadosEvento = require('../models/respCamposPersonalizadosEventoModel');
const CamposPersonalizados = require('../models/camposPersonalizadosModel');
const Usuario = require('../models/usuarioModel'); // Ensure this model exists

// adicionarRespostaCampoPersonalizado
exports.adicionarRespostaCampoPersonalizado = async (req, res) => {
  try {
    const { ID_CAMPOS_PERSONALIZADOS, ID_USUARIO, RESPOSTA_CAMPO } = req.body;

    // Validate foreign keys
    const campoPersonalizado = await CamposPersonalizados.findByPk(ID_CAMPOS_PERSONALIZADOS);
    if (!campoPersonalizado) {
      return res.status(404).json({ error: 'Campo personalizado não encontrado.' });
    }

    const usuario = await Usuario.findByPk(ID_USUARIO);
    if (!usuario) {
      return res.status(404).json({ error: 'Usuário não encontrado.' });
    }

    const novaResposta = await RespCamposPersonalizadosEvento.create({
      ID_CAMPOS_PERSONALIZADOS,
      ID_USUARIO,
      RESPOSTA_CAMPO,
    });

    res.status(201).json(novaResposta);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// editarRespostaCampoPersonalizado
exports.editarRespostaCampoPersonalizado = async (req, res) => {
  try {
    const resposta = await RespCamposPersonalizadosEvento.findByPk(req.params.id);
    if (!resposta) {
      return res.status(404).json({ error: 'Resposta não encontrada.' });
    }

    const { ID_CAMPOS_PERSONALIZADOS, ID_USUARIO } = req.body;

    // Validate foreign keys if they are being updated
    if (ID_CAMPOS_PERSONALIZADOS) {
      const campoPersonalizado = await CamposPersonalizados.findByPk(ID_CAMPOS_PERSONALIZADOS);
      if (!campoPersonalizado) {
        return res.status(404).json({ error: 'Campo personalizado não encontrado.' });
      }
    }

    if (ID_USUARIO) {
      const usuario = await Usuario.findByPk(ID_USUARIO);
      if (!usuario) {
        return res.status(404).json({ error: 'Usuário não encontrado.' });
      }
    }

    await resposta.update(req.body);
    res.status(200).json(resposta);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// removerRespostaCampoPersonalizado
exports.removerRespostaCampoPersonalizado = async (req, res) => {
  try {
    const resposta = await RespCamposPersonalizadosEvento.findByPk(req.params.id);
    if (!resposta) {
      return res.status(404).json({ error: 'Resposta não encontrada.' });
    }

    await resposta.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// listarRespostasCamposPersonalizados
exports.listarRespostasCamposPersonalizados = async (req, res) => {
  try {
    const { idUsuario } = req.query;

    const whereClause = {};
    if (idUsuario) {
      whereClause.ID_USUARIO = idUsuario;
    }

    const respostas = await RespCamposPersonalizadosEvento.findAll({
      where: whereClause,
    });
    res.status(200).json(respostas);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// visualizarRespostaCampoPersonalizado
exports.visualizarRespostaCampoPersonalizado = async (req, res) => {
  try {
    const resposta = await RespCamposPersonalizadosEvento.findByPk(req.params.id, {
      include: [
        {
          model: CamposPersonalizados,
          attributes: ['ID', 'NOME_CAMPO'],
        },
        {
          model: Usuario,
          attributes: ['ID', 'NOME'],
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
