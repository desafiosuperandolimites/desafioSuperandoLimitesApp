const FeedNoticias = require('../models/feedNoticiasModel');
const Usuarios = require('../models/usuarioModel');
const nodemailer = require('nodemailer');
const notificationService = require('../services/notificationService');
const { v4: uuidv4 } = require('uuid');

exports.criarNoticia = async (req, res) => {
  try {
    const { ID_USUARIO, CATEGORIA, TITULO, DESCRICAO, FOTO_CAPA } = req.body;
    if (!ID_USUARIO || !CATEGORIA || !TITULO || !DESCRICAO) {
      return res.status(400).json({ error: 'Campos obrigatórios ausentes.' });
    }

    // Cria a notícia no banco de dados
    const novaNoticia = await FeedNoticias.create({ ID_USUARIO, CATEGORIA, TITULO, DESCRICAO, FOTO_CAPA });

    // Busca todos os usuários para enviar e-mails e notificações
    const todosUsuarios = await Usuarios.findAll({
      where: { SITUACAO: true }
    });
    const nomeList = todosUsuarios.map(usuario => usuario.NOME);
    const emailList = todosUsuarios.map(usuario => usuario.EMAIL);

    // Configura o transporter do Nodemailer
    const transporter = nodemailer.createTransport({
      service: 'Gmail',
      auth: {
        user: 'desafiosuperandolimites.contato@gmail.com', // substitua pelo seu e-mail
        pass: 'tiqt xqhv xjja zmlh'  // substitua pela senha ou app-specific password
      }
    });

    // Estratégia Fire-and-Forget para envio de e-mails
    emailList.forEach((email, index) => {
      const mailOptions = {
        to: email,
        from: 'desafiosuperandolimites.contato@gmail.com',
        subject: 'Nova Notícia Disponível – App Superando Limites!',
        text:
          `Olá, ${nomeList[index]}!\n\n` +
          `Temos novidades para você! Uma nova notícia sobre os eventos esportivos foi publicada em nosso aplicativo. Acesse o app para conferir as atualizações e ficar por dentro de tudo!\n\n` +
          `Esta é uma excelente oportunidade para acompanhar as informações mais recentes sobre os eventos. Esperamos que as novidades sejam úteis para sua experiência conosco!\n\n` +
          `Para acessar a notícia, basta fazer login no app e visitar a seção de notícias.\n\n` +
          `Precisa de ajuda?\n\n` +
          `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
          `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
          `Obrigado por utilizar nossos serviços!\n\n` +
          `Atenciosamente,\n` +
          `Equipe Superando Limites`
      };

      // Dispara o envio sem aguardar o retorno
      transporter.sendMail(mailOptions)
        .then(info => console.log(`Email enviado para ${email}`))
        .catch(error => console.error(`Erro ao enviar e-mail para ${email}:`, error));
    });

    // Estratégia Fire-and-Forget para envio de push notifications
    const title = 'Nova Notícia';
    const body = 'Novidade! Uma nova notícia está disponível no app. Acesse agora e fique por dentro!';
    notificationService.sendNotificationToAllUsers(title, body)
      .then(() => console.log("Push notifications enviadas."))
      .catch(error => console.error("Erro ao enviar push notifications:", error));

    // Responde imediatamente ao cliente
    res.status(201).json(novaNoticia);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Editar notícia existente
exports.editarNoticia = async (req, res) => {
  try {
    const { id } = req.params;
    const { CATEGORIA, TITULO, DESCRICAO, FOTO_CAPA } = req.body;

    const noticia = await FeedNoticias.findByPk(id);
    if (!noticia) {
      return res.status(404).json({ error: 'Notícia não encontrada.' });
    }

    await noticia.update({
      CATEGORIA: CATEGORIA || noticia.CATEGORIA,
      TITULO: TITULO || noticia.TITULO,
      DESCRICAO: DESCRICAO || noticia.DESCRICAO,
      FOTO_CAPA: FOTO_CAPA || noticia.FOTO_CAPA,
    });

    res.status(200).json(noticia);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Remover notícia existente
exports.removerNoticia = async (req, res) => {
  try {
    const { id } = req.params;

    const noticia = await FeedNoticias.findByPk(id);
    if (!noticia) {
      return res.status(404).json({ error: 'Notícia não encontrada.' });
    }

    await noticia.destroy();
    res.status(200).json({ message: 'Notícia removida com sucesso.' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Listar todas as notícias
exports.listarNoticias = async (req, res) => {
  try {
    const noticias = await FeedNoticias.findAll();
    res.status(200).json(noticias);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Visualizar notícia específica
exports.visualizarNoticia = async (req, res) => {
  try {
    const { id } = req.params;
    const noticia = await FeedNoticias.findByPk(id);
    if (!noticia) {
      return res.status(404).json({ error: 'Notícia não encontrada.' });
    }
    res.status(200).json(noticia);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
};

// Gera e retorna o link de compartilhamento para uma notícia
exports.gerarLinkCompartilhamento = async (req, res) => {
  try {
    const { id } = req.params;

    // Busca a notícia
    const noticia = await FeedNoticias.findByPk(id);
    if (!noticia) {
      return res.status(404).json({ error: 'Notícia não encontrada.' });
    }

    // Se não tiver um token, gera agora
    if (!noticia.SHARE_TOKEN) {
      noticia.SHARE_TOKEN = uuidv4();
      await noticia.save();
    }

    // Monta a URL de compartilhamento (pode ser seu domínio real):
    // Exemplo: http://seu-dominio.com/share/<SHARE_TOKEN>
    const shareUrl = `http://192.168.56.1:3000/api/share/${noticia.SHARE_TOKEN}`;

    return res.status(200).json({ shareUrl });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
};

// Lida com o acesso ao link de compartilhamento
exports.redirecionarNoticia = async (req, res) => {
  try {
    const { shareToken } = req.params;

    // Busca a notícia pelo token
    const noticia = await FeedNoticias.findOne({ where: { SHARE_TOKEN: shareToken } });
    if (!noticia) {
      // Caso não exista, redireciona para página de erro ou retorna 404
      return res.status(404).send('Token inválido ou notícia não encontrada.');
    }

    console.log(noticia);

    // Aqui você pode retornar diretamente JSON ou HTML de fallback.
    // Exemplo de HTML simples que tenta abrir o app via deep link (meuapp://news/<shareToken>)
    // e, se não der certo, mostra um resumo e link para download.

    // Exemplo bem simples
    return res.send(`
        <!DOCTYPE html>
        <html lang="pt-BR">
        <head>
          <meta charset="UTF-8" />
          <title>${noticia.TITULO}</title>
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <style>
            body {
              margin: 0;
              font-family: Arial, sans-serif;
              background-color: #f3f3f3;
            }
            .container {
              max-width: 600px;
              margin: 0 auto;
              background: #fff;
              padding: 20px;
            }
            header, footer {
              text-align: center;
            }
            header {
              margin-bottom: 20px;
            }
            h1 {
              font-size: 1.5rem;
              color: #333;
            }
            p {
              font-size: 1rem;
              color: #555;
              line-height: 1.4;
            }
            .logo {
              max-width: 150px; /* Adjust the size of the logo */
              height: auto;
              margin: 0 auto 20px;
              display: block;
            }
            .download-links {
              text-align: center;
              margin: 20px 0;
            }
            .download-links img {
              max-width: 280px; /* Adjust the size of the download buttons */
              height: auto;
              margin: 10px;
            }
            .open-app-container {
              text-align: center;
              margin: 20px 0;
            }
            .open-app-btn {
              display: inline-block;
              margin: 20px auto;
              padding: 15px 20px;
              background-color: #FF7801;
              color: #fff;
              text-decoration: none;
              border-radius: 8px;
              font-size: 1.2rem;
              font-weight: bold;
              box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
              transition: background-color 0.3s, box-shadow 0.3s;
              text-align: center;
            }
            .open-app-btn:hover {
              background-color: #FF7801;
              box-shadow: 0 6px 10px rgba(0, 0, 0, 0.2);
            }
            .image-container {
              text-align: center;
              margin-bottom: 20px;
            }
            .image-container img {
              max-width: 100%;
              height: auto;
              border-radius: 8px;
            }
          </style>
          <script>
            // Tenta abrir o app            
            setTimeout(function() {
          window.location.href = "superandolimites://noticia/${noticia.SHARE_TOKEN}";
        }, 1000); // 1 second timeout
          </script>
        </head>
        <body>
          <div class="container">
            <header>
              <img class="logo" src="/static/logo.png" alt="Logo"> <!-- Adjusted logo size -->
              <h1>${noticia.TITULO}</h1>
            </header>

            <p>${noticia.DESCRICAO}</p>

            <p>
              <strong>Não abriu o aplicativo?</strong><br/>
              Se você já tem o app instalado, tente:
            </p>

            <div class="open-app-container">
              <a class="open-app-btn" href="superandolimites://noticia/${noticia.SHARE_TOKEN}">
                Abrir no App
              </a>
            </div>

            <p>
              Caso não tenha o aplicativo instalado, faça o download:
            </p>

            <div class="download-links">
              <a href="https://play.google.com/store/apps/details?id=br.com.seuprojeto.app" target="_blank">
                <img src="/static/Botão-GooglePlay.png" alt="Baixar no Google Play">
              </a>
              <a href="https://apps.apple.com/us/app/exemplo/id12345678" target="_blank">
                <img src="/static/Botão-AppStore.png" alt="Baixar na App Store">
              </a>
            </div>

            <footer>
              <p>&copy; ${new Date().getFullYear()} - Superando Limites</p>
            </footer>
          </div>
        </body>
        </html>
        `);
  } catch (error) {
    console.error(error);
    return res.status(500).send('Erro interno do servidor');
  }
};

exports.getNoticiaByShareToken = async (req, res) => {
  try {
    const { shareToken } = req.params;
    const noticia = await FeedNoticias.findOne({ where: { SHARE_TOKEN: shareToken } });
    if (!noticia) {
      return res.status(404).json({ error: 'Notícia não encontrada.' });
    }
    return res.json(noticia);
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: error.message });
  }
};
