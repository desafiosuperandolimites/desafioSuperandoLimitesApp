const PagamentoInscricao = require('../models/pagamentosInscricoesModel');
const Usuario = require('../models/usuarioModel');
const InscricaoEvento = require('../models/inscricaoEventoModel');
const Evento = require('../models/eventoModel');
const StatusPagamento = require('../models/statusPagamentoModel');
const nodemailer = require('nodemailer');
const notificationService = require('../services/notificationService');


// Adicionar novo pagamento
exports.adicionarPagamentoInscricao = async (req, res) => {
  try {
    const {
      ID_USUARIO,
      ID_INSCRICAO_EVENTO,
      ID_DADOS_BANCARIOS_ADM,
      ID_STATUS_PAGAMENTO,
      COMPROVANTE,
      DATA_PAGAMENTO,
      MOTIVO,
    } = req.body;

    const usuarioAdmin = await Usuario.findByPk(1);

    const usuario = await Usuario.findByPk(ID_USUARIO);
    if (!usuario) return res.status(400).json({ error: 'Usuário inválido.' });

    const inscricao = await InscricaoEvento.findByPk(ID_INSCRICAO_EVENTO);
    if (!inscricao) return res.status(400).json({ error: 'Inscrição inválida.' });

    const evento = await Evento.findByPk(inscricao.ID_EVENTO);
    if (!evento) return res.status(400).json({ error: 'Evento inválido.' });

    const statusPagamento = await StatusPagamento.findByPk(ID_STATUS_PAGAMENTO);
    if (!statusPagamento) return res.status(400).json({ error: 'Status de pagamento inválido.' });

    // Validação de dados obrigatórios
    if (!ID_USUARIO || !ID_INSCRICAO_EVENTO || !ID_STATUS_PAGAMENTO) {
      return res.status(400).json({ error: 'Campos obrigatórios ausentes.' });
    }

    const novoPagamento = await PagamentoInscricao.create({
      ID_USUARIO,
      ID_INSCRICAO_EVENTO,
      ID_DADOS_BANCARIOS_ADM,
      ID_STATUS_PAGAMENTO,
      COMPROVANTE,
      DATA_PAGAMENTO,
      MOTIVO,
    });

    const transporter = nodemailer.createTransport({
      service: 'Gmail', // or use another email service
      auth: {
        user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
        pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
      }
    });

    const mailOptions = {
      to: usuarioAdmin.EMAIL,
      from: 'desafiosuperandolimites.contato@gmail.com',
      subject: 'Atualização no Status de Pagamento da Inscrição',
      text: `Olá ${usuarioAdmin.NOME},\n\n` +
        `Estamos enviando esta mensagem para informar que o status do pagamento da inscrição do usuário ${usuario.NOME}, ${usuario.EMAIL}, no evento ${evento.NOME} foi atualizado. Confira os detalhes:\n` +
        `  - Status Atual: ${statusPagamento.DESCRICAO}\n\n` +
        `Para mais informações, acesse o aplicativo e verifique as atualizações do pagamento. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
        `Precisa de ajuda?\n\n` +
        `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
        `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
        `Obrigado por utilizar nossos serviços!\n\n` +
        `Atenciosamente,\n` +
        `Equipe Superando Limites`
    };

    // Send the email
    if (usuarioAdmin.SITUACAO) {
      transporter.sendMail(mailOptions)
        .then(() => console.log(`Email enviado para ${usuarioAdmin.EMAIL}`))
        .catch(error => console.error(`Erro ao enviar email:`, error));
  
      // Send push notification to the admin user
      const title = 'Alteração de Status de Pagamento';
      const body = `O pagamento do usuário ${usuario.NOME}, ${usuario.EMAIL},  no evento ${evento.NOME} foi atualizado para: ${statusPagamento.DESCRICAO}. Acesse o app para mais detalhes!`;
      notificationService.sendNotificationToUser(usuarioAdmin.ID, title, body)
        .then(() => console.log(`Push notification enviada para ${usuarioAdmin.ID}`))
        .catch(error => console.error(`Erro ao enviar push notification:`, error));
    }


    res.status(201).json(novoPagamento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

exports.buscarPagamentoPorInscricao = async (req, res) => {
  try {
    const { idInscricaoEvento } = req.params;

    // Buscar pagamento com base no ID_INSCRICAO_EVENTO
    const pagamento = await PagamentoInscricao.findOne({
      where: { ID_INSCRICAO_EVENTO: idInscricaoEvento },
    });

    if (!pagamento) {
      return res.status(404).json({ error: 'Pagamento não encontrado.' });
    }

    res.status(200).json(pagamento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};


// Editar pagamento existente e atualizar status de pagamento
exports.editarPagamentoInscricao = async (req, res) => {
  try {
    const { id } = req.params;
    const { ID_STATUS_PAGAMENTO, DATA_PAGAMENTO, COMPROVANTE, MOTIVO } = req.body;

    // Localizar o pagamento pelo ID
    const pagamento = await PagamentoInscricao.findByPk(id);
    if (!pagamento) {
      return res.status(404).json({ error: 'Pagamento não encontrado.' });
    }

    const usuarioAdmin = await Usuario.findByPk(1);

    const usuario = await Usuario.findByPk(pagamento.ID_USUARIO);
    if (!usuario) return res.status(400).json({ error: 'Usuário inválido.' });

    const inscricao = await InscricaoEvento.findByPk(pagamento.ID_INSCRICAO_EVENTO);
    if (!inscricao) return res.status(400).json({ error: 'Inscrição inválida.' });

    const evento = await Evento.findByPk(inscricao.ID_EVENTO);
    if (!evento) return res.status(400).json({ error: 'Evento inválido.' });

    const statusPagamento = await StatusPagamento.findByPk(ID_STATUS_PAGAMENTO);
    if (!statusPagamento) return res.status(400).json({ error: 'Status de pagamento inválido.' });

    // Atualizar os campos fornecidos
    await pagamento.update({ ID_STATUS_PAGAMENTO: ID_STATUS_PAGAMENTO, DATA_PAGAMENTO: DATA_PAGAMENTO, COMPROVANTE: COMPROVANTE, MOTIVO: MOTIVO });

    const transporter = nodemailer.createTransport({
      service: 'Gmail', // or use another email service
      auth: {
        user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
        pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
      }
    });

    const mailOptions = {
      to: usuarioAdmin.EMAIL,
      from: 'desafiosuperandolimites.contato@gmail.com',
      subject: 'Atualização no Status de Pagamento da Inscrição',
      text: `Olá ${usuarioAdmin.NOME},\n\n` +
        `Estamos enviando esta mensagem para informar que o status do pagamento da inscrição do usuário ${usuario.NOME}, ${usuario.EMAIL}, no evento ${evento.NOME} foi atualizado. Confira os detalhes:\n` +
        `  - Status Atual: ${statusPagamento.DESCRICAO}\n\n` +
        `Para mais informações, acesse o aplicativo e verifique as atualizações do pagamento. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
        `Precisa de ajuda?\n\n` +
        `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
        `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
        `Obrigado por utilizar nossos serviços!\n\n` +
        `Atenciosamente,\n` +
        `Equipe Superando Limites`
    };

    // Send the email
    if (usuarioAdmin.SITUACAO) {
      transporter.sendMail(mailOptions)
        .then(() => console.log(`Email enviado para ${usuarioAdmin.EMAIL}`))
        .catch(error => console.error(`Erro ao enviar email:`, error));
  
      // Send push notification to the admin user
      const title = 'Alteração de Status de Pagamento';
      const body = `O pagamento do usuário ${usuario.NOME}, ${usuario.EMAIL},  no evento ${evento.NOME} foi atualizado para: ${statusPagamento.DESCRICAO}. Acesse o app para mais detalhes!`;
      notificationService.sendNotificationToUser(usuarioAdmin.ID, title, body)
        .then(() => console.log(`Push notification enviada para ${usuarioAdmin.ID}`))
        .catch(error => console.error(`Erro ao enviar push notification:`, error));
    }

    // Retornar o pagamento atualizado
    res.status(200).json(pagamento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Remover pagamento existente
exports.removerPagamentoInscricao = async (req, res) => {
  try {
    const { id } = req.params;
    const pagamento = await PagamentoInscricao.findByPk(id);
    if (!pagamento) {
      return res.status(404).json({ error: 'Pagamento não encontrado.' });
    }

    await pagamento.destroy();
    return res.status(204).send();
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Listar todos os pagamentos
exports.listarPagamentosInscricao = async (req, res) => {
  try {
    const pagamentos = await PagamentoInscricao.findAll();
    res.status(200).json(pagamentos);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Visualizar dados de um pagamento específico
exports.visualizarDadosPagamento = async (req, res) => {
  try {
    const { id } = req.params;
    const pagamento = await PagamentoInscricao.findByPk(id);
    if (!pagamento) {
      return res.status(404).json({ error: 'Pagamento não encontrado.' });
    }
    res.status(200).json(pagamento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Aprovar pagamento
exports.aprovarPagamentoInscricao = async (req, res) => {
  try {
    const { id } = req.params;

    const pagamento = await PagamentoInscricao.findByPk(id);
    if (!pagamento) {
      return res.status(404).json({ error: 'Pagamento não encontrado.' });
    }

    const usuarioAdmin = await Usuario.findByPk(1);

    const usuario = await Usuario.findByPk(pagamento.ID_USUARIO);
    if (!usuario) return res.status(400).json({ error: 'Usuário inválido.' });

    const inscricao = await InscricaoEvento.findByPk(pagamento.ID_INSCRICAO_EVENTO);
    if (!inscricao) return res.status(400).json({ error: 'Inscrição inválida.' });

    const evento = await Evento.findByPk(inscricao.ID_EVENTO);
    if (!evento) return res.status(400).json({ error: 'Evento inválido.' });

    const statusPagamento = await StatusPagamento.findByPk(2);
    if (!statusPagamento) return res.status(400).json({ error: 'Status de pagamento inválido.' });

    // Atualize o status para "Pago" (supondo que 2 seja "Pago")
    await pagamento.update({
      ID_STATUS_PAGAMENTO: 2, // Status "Pago"
    });

    const transporter = nodemailer.createTransport({
      service: 'Gmail', // or use another email service
      auth: {
        user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
        pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
      }
    });

    const mailOptions = {
      to: usuarioAdmin.EMAIL,
      from: 'desafiosuperandolimites.contato@gmail.com',
      subject: 'Atualização no Status de Pagamento da Inscrição',
      text: `Olá ${usuarioAdmin.NOME},\n\n` +
        `Estamos enviando esta mensagem para informar que o status do pagamento da inscrição do usuário ${usuario.NOME}, ${usuario.EMAIL}, no evento ${evento.NOME} foi atualizado. Confira os detalhes:\n` +
        `  - Status Atual: ${statusPagamento.DESCRICAO}\n\n` +
        `Para mais informações, acesse o aplicativo e verifique as atualizações do pagamento. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
        `Precisa de ajuda?\n\n` +
        `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
        `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
        `Obrigado por utilizar nossos serviços!\n\n` +
        `Atenciosamente,\n` +
        `Equipe Superando Limites`
    };

    if (usuarioAdmin.SITUACAO) {
      // Send the email
      transporter.sendMail(mailOptions)
        .then(() => console.log(`Email enviado para ${usuarioAdmin.EMAIL}`))
        .catch(error => console.error(`Erro ao enviar email:`, error));
  
      // Send push notification to the admin user
      const title = 'Alteração de Status de Pagamento';
      const body = `O pagamento do usuário ${usuario.NOME}, ${usuario.EMAIL},  no evento ${evento.NOME} foi atualizado para: ${statusPagamento.DESCRICAO}. Acesse o app para mais detalhes!`;
      notificationService.sendNotificationToUser(usuarioAdmin.ID, title, body)
        .then(() => console.log(`Push notification enviada para ${usuarioAdmin.ID}`))
        .catch(error => console.error(`Erro ao enviar push notification:`, error));
    }

    res.status(200).json(pagamento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Rejeitar pagamento
exports.rejeitarPagamentoInscricao = async (req, res) => {
  try {
    const { id } = req.params;
    const { MOTIVO } = req.body;

    const pagamento = await PagamentoInscricao.findByPk(id);
    if (!pagamento) {
      return res.status(404).json({ error: 'Pagamento não encontrado.' });
    }

    const usuarioAdmin = await Usuario.findByPk(1);

    const usuario = await Usuario.findByPk(pagamento.ID_USUARIO);
    if (!usuario) return res.status(400).json({ error: 'Usuário inválido.' });

    const inscricao = await InscricaoEvento.findByPk(pagamento.ID_INSCRICAO_EVENTO);
    if (!inscricao) return res.status(400).json({ error: 'Inscrição inválida.' });

    const evento = await Evento.findByPk(inscricao.ID_EVENTO);
    if (!evento) return res.status(400).json({ error: 'Evento inválido.' });

    const statusPagamento = await StatusPagamento.findByPk(3);
    if (!statusPagamento) return res.status(400).json({ error: 'Status de pagamento inválido.' });

    // Atualize o status para "Em revisão" (supondo que 3 seja "Em revisão") e armazene o motivo fornecido pelo usuário
    await pagamento.update({
      ID_STATUS_PAGAMENTO: 3, // Status "Em revisão"
      MOTIVO: MOTIVO, // Motivo digitado pelo usuário
    });

    const transporter = nodemailer.createTransport({
      service: 'Gmail', // or use another email service
      auth: {
        user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
        pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
      }
    });

    const mailOptions = {
      to: usuarioAdmin.EMAIL,
      from: 'desafiosuperandolimites.contato@gmail.com',
      subject: 'Atualização no Status de Pagamento da Inscrição',
      text: `Olá ${usuarioAdmin.NOME},\n\n` +
        `Estamos enviando esta mensagem para informar que o status do pagamento da inscrição do usuário ${usuario.NOME}, ${usuario.EMAIL}, no evento ${evento.NOME} foi atualizado. Confira os detalhes:\n` +
        `  - Status Atual: ${statusPagamento.DESCRICAO}\n\n` +
        `Para mais informações, acesse o aplicativo e verifique as atualizações do pagamento. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
        `Precisa de ajuda?\n\n` +
        `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
        `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
        `Obrigado por utilizar nossos serviços!\n\n` +
        `Atenciosamente,\n` +
        `Equipe Superando Limites`
    };

    // Send the email
    if (usuarioAdmin.SITUACAO) {
      transporter.sendMail(mailOptions)
        .then(() => console.log(`Email enviado para ${usuarioAdmin.EMAIL}`))
        .catch(error => console.error(`Erro ao enviar email:`, error));
  
      // Send push notification to the admin user
      const title = 'Alteração de Status de Pagamento';
      const body = `O pagamento do usuário ${usuario.NOME}, ${usuario.EMAIL},  no evento ${evento.NOME} foi atualizado para: ${statusPagamento.DESCRICAO}. Acesse o app para mais detalhes!`;
      notificationService.sendNotificationToUser(usuarioAdmin.ID, title, body)
        .then(() => console.log(`Push notification enviada para ${usuarioAdmin.ID}`))
        .catch(error => console.error(`Erro ao enviar push notification:`, error));
    }

    res.status(200).json(pagamento);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};
