// controllers/camposPersonalizadosController.js

const GruposEvento = require('../models/gruposEventoModel');
const TipoCampo = require('../models/tipoCampo');
const CamposPersonalizados = require('../models/camposPersonalizadosModel');

// adicionarCampoPersonalizado
exports.adicionarCampoPersonalizado = async (req, res) => {
  try {
    const { ID_GRUPOS_EVENTO, ID_TIPO_CAMPO, NOME_CAMPO, OBRIGATORIO, SITUACAO } = req.body;

    // Validate foreign keys
    const grupoEvento = await GruposEvento.findByPk(ID_GRUPOS_EVENTO);
    if (!grupoEvento) {
      return res.status(404).json({ error: 'Grupo de evento não encontrado.' });
    }

    const tipoCampo = await TipoCampo.findByPk(ID_TIPO_CAMPO);
    if (!tipoCampo) {
      return res.status(404).json({ error: 'Tipo de campo não encontrado.' });
    }

    const novoCampo = await CamposPersonalizados.create({
      ID_GRUPOS_EVENTO,
      ID_TIPO_CAMPO,
      NOME_CAMPO,
      OBRIGATORIO,
      SITUACAO,
    });

    res.status(201).json(novoCampo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// editarCampoPersonalizado
exports.editarCampoPersonalizado = async (req, res) => {
  try {
    const campo = await CamposPersonalizados.findByPk(req.params.id);
    if (!campo) {
      return res.status(404).json({ error: 'Campo personalizado não encontrado.' });
    }

    const { ID_GRUPOS_EVENTO, ID_TIPO_CAMPO } = req.body;

    // Validate foreign keys if they are being updated
    if (ID_GRUPOS_EVENTO) {
      const grupoEvento = await GruposEvento.findByPk(ID_GRUPOS_EVENTO);
      if (!grupoEvento) {
        return res.status(404).json({ error: 'Grupo de evento não encontrado.' });
      }
    }

    if (ID_TIPO_CAMPO) {
      const tipoCampo = await TipoCampo.findByPk(ID_TIPO_CAMPO);
      if (!tipoCampo) {
        return res.status(404).json({ error: 'Tipo de campo não encontrado.' });
      }
    }

    await campo.update(req.body);
    res.status(200).json(campo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// ativarDesativarCampoPersonalizado
exports.ativarDesativarCampoPersonalizado = async (req, res) => {
  try {
    const campo = await CamposPersonalizados.findByPk(req.params.id);
    if (!campo) {
      return res.status(404).json({ error: 'Campo personalizado não encontrado.' });
    }

    campo.SITUACAO = !campo.SITUACAO;
    await campo.save();

    res.status(200).json({
      message: `Campo ${campo.SITUACAO ? 'ativado' : 'desativado'} com sucesso.`,
      campo,
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// removerCampoPersonalizado
exports.removerCampoPersonalizado = async (req, res) => {
  try {
    const campo = await CamposPersonalizados.findByPk(req.params.id);
    if (!campo) {
      return res.status(404).json({ error: 'Campo personalizado não encontrado.' });
    }

    await campo.destroy();
    res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// listarCamposPersonalizados
exports.listarCamposPersonalizados = async (req, res) => {
  try {
    const { idGruposEvento } = req.query;

    const whereClause = {};
    if (idGruposEvento) {
      whereClause.ID_GRUPOS_EVENTO = idGruposEvento;
    }

    const camposPersonalizados = await CamposPersonalizados.findAll({
      where: whereClause,
      include: [
        {
          model: TipoCampo,
          attributes: ['ID', 'DESCRICAO'],
        },
      ],
    });
    res.status(200).json(camposPersonalizados);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// visualizarCampoPersonalizado
exports.visualizarCampoPersonalizado = async (req, res) => {
  try {
    const campo = await CamposPersonalizados.findByPk(req.params.id, {
      include: [
        {
          model: GruposEvento,
          attributes: ['ID', 'NOME'],
        },
        {
          model: TipoCampo,
          attributes: ['ID', 'DESCRICAO'],
        },
      ],
    });
    if (!campo) {
      return res.status(404).json({ error: 'Campo personalizado não encontrado.' });
    }
    res.status(200).json(campo);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
