// server.js

const cron = require('node-cron');
require('dotenv').config();
const express = require('express');
const { Op } = require('sequelize');
const cors = require('cors');
const db = require('./database/db');
const Evento = require('./models/eventoModel');
const Usuario = require('./models/usuarioModel');
const nodemailer = require('nodemailer');
const notificationService = require('./services/notificationService');
const path = require('path');
const InscricaoEvento = require('./models/inscricaoEventoModel');


// Configure the email transporter
const transporter = nodemailer.createTransport({
  service: 'Gmail', // ou outro serviço de email
  auth: {
    user: 'desafiosuperandolimites.contato@gmail.com', // substitua pelo seu e-mail
    pass: 'tiqt xqhv xjja zmlh'   // substitua pela sua senha ou senha de app
  }
});

// Agenda a tarefa para rodar diariamente em um horário específico, por exemplo, 10:57
cron.schedule('23 14 * * *', async () => {
  try {
    // Calcula a data alvo (3 dias a partir de hoje)
    const targetDate = new Date();
    targetDate.setDate(targetDate.getDate() + 3);
    targetDate.setHours(0, 0, 0, 0); // zera a hora para comparação de datas

    // Formata a data no padrão 'YYYY-MM-DD'
    const formattedDate = targetDate.toISOString().split('T')[0];

    // Busca os eventos cujo DATA_FIM_INSCRICAO seja igual à data alvo e que estejam ativos
    const eventos = await Evento.findAll({
      where: {
        DATA_FIM_INSCRICAO: {
          [Op.eq]: formattedDate
        },
        SITUACAO: true
      }
    });

    if (eventos.length > 0) {
      for (const evento of eventos) {
        // Primeiro, busca as inscrições já realizadas para o evento
        const inscricoes = await InscricaoEvento.findAll({
          where: { ID_EVENTO: evento.ID },
          attributes: ['ID_USUARIO']
        });
        // Cria um array com os IDs dos usuários inscritos
        const inscritosIds = inscricoes.map(inscricao => inscricao.ID_USUARIO);

        // Busca os usuários do grupo do evento que ainda não se inscreveram
        // É esperado que o evento possua um campo que relacione ao grupo, por exemplo, ID_GRUPO_EVENTO
        const usuariosDoGrupo = await Usuario.findAll({
          where: {
            SITUACAO: true,
            ID_GRUPO_EVENTO: evento.ID_GRUPO_EVENTO, // Filtra usuários do mesmo grupo do evento
            ID: {
              [Op.notIn]: inscritosIds // Exclui usuários que já se inscreveram
            }
          }
        });

        // Envia email e notificação para cada usuário que ainda não se inscreveu
        for (const usuario of usuariosDoGrupo) {
          const mailOptions = {
            to: usuario.EMAIL,
            from: 'desafiosuperandolimites.contato@gmail.com',
            subject: '⏳ Última Chamada: Inscrições Encerram em 2 Dias!',
            text: `Olá, ${usuario.NOME}!\n\n` +
              `O prazo para se inscrever no evento "${evento.NOME}" está quase acabando! ⏰ Faltam apenas 2 dias para o encerramento das inscrições.\n\n` +
              `Não perca essa oportunidade de participar e desafiar a si mesmo! Caso ainda não tenha finalizado sua inscrição, acesse o app e garanta seu lugar no evento.\n\n` +
              `Estamos prontos para te receber e torcendo para que você faça parte dessa jornada!\n\n` +
              `Corra e inscreva-se já!\n\n` +
              `Precisa de ajuda?\n\n` +
              `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
              `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
              `Obrigado por utilizar nossos serviços!\n\n` +
              `Atenciosamente,\n` +
              `Equipe Superando Limites`
          };

          // Envia o e-mail (fire-and-forget)
          transporter.sendMail(mailOptions)
            .then(() => console.log(`Email sent to ${usuario.EMAIL}`))
            .catch(err => console.error(`Error sending email to ${usuario.EMAIL}:`, err));

          const title = 'Período de Inscrição';
          const body = `⏰ Última chamada! Restam apenas 2 dias para se inscrever no evento ${evento.NOME}! Não perca!`;
          // Envia a notificação (fire-and-forget)
          notificationService.sendNotificationToUser(usuario.ID, title, body)
            .then(() => console.log(`Notification sent to user ${usuario.ID}`))
            .catch(err => console.error(`Error sending notification to user ${usuario.ID}:`, err));
        }
      }
      console.log('Emails e notificações agendados enviados para usuários não inscritos nos eventos.');
    } else {
      console.log('Nenhum evento com inscrições encerrando em 2 dias.');
    }
  } catch (error) {
    console.error('Error in scheduled task:', error.message);
  }
});

// Importa as rotas agrupadas
const routes = require('./routes');

const app = express();

// Middlewares globais
app.use(express.json());
app.use(cors());

// Usando todas as rotas agrupadas
app.use('/api', routes);
app.use('/static', express.static(path.join(__dirname, 'images_noticias')));

// Porta do servidor
const PORT = process.env.PORT || 3000;

// Conexão ao banco de dados e start do servidor
db.authenticate()
  .then(() => {
    console.log('Conexão ao banco de dados estabelecida com sucesso.');
    return db.sync(); // Sincroniza o banco de dados (ajusta a estrutura se necessário)
  })
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Servidor rodando na porta ${PORT}`);
    });
  })
  .catch(err => {
    console.error('Falha ao conectar ao banco de dados:', err);
  });
