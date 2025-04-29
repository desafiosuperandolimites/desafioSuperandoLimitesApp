const Notificacao = require('../models/notificacoesModel');

exports.markAsRead = async (req, res) => {
  try {
    const { id } = req.params;

    const notificacao = await Notificacao.findByPk(id);
    if (!notificacao) {
      return res.status(404).json({ error: 'Notificação não encontrada.' });
    }

    notificacao.LIDA = true;
    await notificacao.save();

    return res.status(200).json({ message: 'Notificação marcada como lida.' });
  } catch (error) {
    console.error('Error marking notification as read:', error);
    return res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};

exports.getNotificationsForUser = async (req, res) => {
  try {
    const {ID_USUARIO} = req.query;

    const notificacoes = await Notificacao.findAll({
      where: { ID_USUARIO: ID_USUARIO },
      order: [['CRIADO_EM', 'DESC']]
    });

    // Optional: format or filter notifications if needed
    return res.status(200).json(notificacoes);
  } catch (error) {
    console.error('Error fetching notifications:', error);
    return res.status(500).json({ error: 'Erro interno do servidor.' });
  }
};
