const { Op } = require('sequelize');
const InscricaoEvento = require('../models/inscricaoEventoModel');
const Usuario = require('../models/usuarioModel');
const CategoriaBicicleta = require('../models/categoriaBicicletaModel');
const CategoriaCaminhadaCorrida = require('../models/categoriaCaminhadaCorridaModel');
const StatusInscricao = require('../models/statusInscricaoModel');
const Evento = require('../models/eventoModel');
const nodemailer = require('nodemailer');
const notificationService = require('../services/notificationService');



// Listar todas as inscrições com opções de busca, ordenação e filtragem
exports.listarInscricoes = async (req, res) => {
    try {
        const { userId } = req.query;

        const whereClause = {};
        if (userId) {
            whereClause.ID_USUARIO = userId;
        }
        const inscricoes = await InscricaoEvento.findAll({
            where: whereClause,

        });

        res.status(200).json(inscricoes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Listar todas as inscrições com opções de busca, ordenação e filtragem
exports.listarInscricoesByEvento = async (req, res) => {
    try {
        const { eventoId } = req.query;

        const whereClause = {};
        if (eventoId) {
            whereClause.ID_EVENTO = eventoId;
        }
        const inscricoes = await InscricaoEvento.findAll({
            where: whereClause,
        });

        res.status(200).json(inscricoes);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Criar uma nova inscrição
exports.criarInscricao = async (req, res) => {
    try {
        const {
            ID_USUARIO,
            ID_CATEGORIA_BICICLETA,
            ID_CATEGORIA_CAMINHADA_CORRIDA,
            ID_STATUS_INSCRICAO_TIPO,
            ID_EVENTO,
            META,
            TERMO_CIENTE,
        } = req.body;

        // Validações dos campos obrigatórios
        if (!ID_USUARIO) return res.status(400).json({ error: 'ID_USUARIO é obrigatório.' });
        if (!ID_STATUS_INSCRICAO_TIPO) return res.status(400).json({ error: 'ID_STATUS_INSCRICAO_TIPO é obrigatório.' });
        if (!ID_EVENTO) return res.status(400).json({ error: 'ID_EVENTO é obrigatório.' });
        if (META === undefined) return res.status(400).json({ error: 'META é obrigatório.' });
        if (TERMO_CIENTE === undefined) return res.status(400).json({ error: 'TERMO_CIENTE é obrigatório.' });

        // Validação das chaves estrangeiras
        const usuario = await Usuario.findByPk(ID_USUARIO);
        if (!usuario) return res.status(400).json({ error: 'Usuário inválido.' });

        if (ID_CATEGORIA_BICICLETA) {
            const categoriaBicicleta = await CategoriaBicicleta.findByPk(ID_CATEGORIA_BICICLETA);
            if (!categoriaBicicleta) return res.status(400).json({ error: 'Categoria de bicicleta inválida.' });
        }

        if (ID_CATEGORIA_CAMINHADA_CORRIDA) {
            const categoriaCaminhada = await CategoriaCaminhadaCorrida.findByPk(ID_CATEGORIA_CAMINHADA_CORRIDA);
            if (!categoriaCaminhada) return res.status(400).json({ error: 'Categoria de caminhada/corrida inválida.' });
        }

        const statusInscricao = await StatusInscricao.findByPk(ID_STATUS_INSCRICAO_TIPO);
        if (!statusInscricao) return res.status(400).json({ error: 'Status de inscrição inválido.' });

        const evento = await Evento.findByPk(ID_EVENTO);
        if (!evento) return res.status(400).json({ error: 'Evento inválido.' });

        const novaInscricao = await InscricaoEvento.create({
            ID_USUARIO,
            ID_CATEGORIA_BICICLETA,
            ID_CATEGORIA_CAMINHADA_CORRIDA,
            ID_STATUS_INSCRICAO_TIPO,
            ID_EVENTO,
            META,
            TERMO_CIENTE,
            // CRIADO_EM e ATUALIZADO_EM serão preenchidos automaticamente
        });

        const transporter = nodemailer.createTransport({
            service: 'Gmail', // or use another email service
            auth: {
                user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
            }
        });

        const mailOptions = {
            to: usuario.EMAIL,
            from: 'desafiosuperandolimites.contato@gmail.com',
            subject: 'Atualização no Status da Sua Inscrição no Evento',
            text: `Olá ${usuario.NOME},\n\n` +
                `Estamos enviando esta mensagem para informar que o status de sua inscrição no evento ${evento.NOME} foi atualizado. Confira os detalhes:\n` +
                `  - Status Atual: ${statusInscricao.DESCRICAO}\n\n` +
                `Para mais informações, acesse o aplicativo e verifique as atualizações na sua inscrição. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
                `Precisa de ajuda?\n\n` +
                `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                `Obrigado por utilizar nossos serviços!\n\n` +
                `Atenciosamente,\n` +
                `Equipe Superando Limites`
        };

        // Send the email
        if (usuario.SITUACAO) {
            transporter.sendMail(mailOptions)
                .then(() => console.log(`Email enviado para ${usuario.EMAIL}`))
                .catch(error => console.error(`Erro ao enviar email:`, error));
    
            // Send push notification to the user
            const title = 'Alteração de Status de Inscrição';
            const body = `Sua inscrição no evento ${evento.NOME} foi atualizada para: ${statusInscricao.DESCRICAO}. Acesse o app para mais detalhes!`;
            notificationService.sendNotificationToUser(ID_USUARIO, title, body)
                .then(() => console.log(`Push notification enviada para ${ID_USUARIO}`))
                .catch(error => console.error(`Erro ao enviar push notification:`, error));
        }


        res.status(201).json(novaInscricao);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Editar uma inscrição específica
exports.editarInscricao = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            ID_USUARIO,
            ID_CATEGORIA_BICICLETA,
            ID_CATEGORIA_CAMINHADA_CORRIDA,
            ID_STATUS_INSCRICAO_TIPO,
            ID_EVENTO,
            META,
            TERMO_CIENTE,
        } = req.body;

        const inscricao = await InscricaoEvento.findByPk(id);
        if (!inscricao) {
            return res.status(404).json({ error: 'Inscrição não encontrada.' });
        }


        // Validações e atualizações

        const usuario = await Usuario.findByPk(ID_USUARIO);
        if (!usuario) return res.status(400).json({ error: 'Usuário inválido.' });
        inscricao.ID_USUARIO = ID_USUARIO;


        if (ID_CATEGORIA_BICICLETA) {
            const categoriaBicicleta = await CategoriaBicicleta.findByPk(ID_CATEGORIA_BICICLETA);
            if (!categoriaBicicleta) return res.status(400).json({ error: 'Categoria de bicicleta inválida.' });
            inscricao.ID_CATEGORIA_BICICLETA = ID_CATEGORIA_BICICLETA;
        }

        if (ID_CATEGORIA_CAMINHADA_CORRIDA) {
            const categoriaCaminhada = await CategoriaCaminhadaCorrida.findByPk(ID_CATEGORIA_CAMINHADA_CORRIDA);
            if (!categoriaCaminhada) return res.status(400).json({ error: 'Categoria de caminhada/corrida inválida.' });
            inscricao.ID_CATEGORIA_CAMINHADA_CORRIDA = ID_CATEGORIA_CAMINHADA_CORRIDA;
        }



        const evento = await Evento.findByPk(ID_EVENTO);
        if (!evento) return res.status(400).json({ error: 'Evento inválido.' });
        inscricao.ID_EVENTO = ID_EVENTO;


        if (META !== undefined) inscricao.META = META;
        if (TERMO_CIENTE !== undefined) inscricao.TERMO_CIENTE = TERMO_CIENTE;

        inscricao.ATUALIZADO_EM = new Date();

        if (ID_STATUS_INSCRICAO_TIPO !== inscricao.ID_STATUS_INSCRICAO_TIPO) {
            const statusInscricao = await StatusInscricao.findByPk(ID_STATUS_INSCRICAO_TIPO);
            if (!statusInscricao) return res.status(400).json({ error: 'Status de inscrição inválido.' });
            inscricao.ID_STATUS_INSCRICAO_TIPO = ID_STATUS_INSCRICAO_TIPO;

            const transporter = nodemailer.createTransport({
                service: 'Gmail', // or use another email service
                auth: {
                    user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                    pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
                }
            });

            const mailOptions = {
                to: usuario.EMAIL,
                from: 'desafiosuperandolimites.contato@gmail.com',
                subject: 'Atualização no Status da Sua Inscrição no Evento',
                text: `Olá ${usuario.NOME},\n\n` +
                    `Estamos enviando esta mensagem para informar que o status de sua inscrição no evento ${evento.NOME} foi atualizado. Confira os detalhes:\n` +
                    `  - Status Atual: ${statusInscricao.DESCRICAO}\n\n` +
                    `Para mais informações, acesse o aplicativo e verifique as atualizações na sua inscrição. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
                    `Precisa de ajuda?\n\n` +
                    `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                    `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                    `Obrigado por utilizar nossos serviços!\n\n` +
                    `Atenciosamente,\n` +
                    `Equipe Superando Limites`
            };

            // Send the email
            if (usuario.SITUACAO) {
                transporter.sendMail(mailOptions)
                    .then(() => console.log(`Email enviado para ${usuario.EMAIL}`))
                    .catch(error => console.error(`Erro ao enviar email:`, error));
    
                // Send push notification to the user
                const title = 'Alteração de Status de Inscrição';
                const body = `Sua inscrição no evento ${evento.NOME} foi atualizada para: ${statusInscricao.DESCRICAO}. Acesse o app para mais detalhes!`;
                notificationService.sendNotificationToUser(ID_USUARIO, title, body)
                    .then(() => console.log(`Push notification enviada para ${ID_USUARIO}`))
                    .catch(error => console.error(`Erro ao enviar push notification:`, error));
            }
        }

        await inscricao.save();
        res.status(200).json(inscricao);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Excluir uma inscrição específica
exports.deletarInscricao = async (req, res) => {
    try {
        const { id } = req.params;

        const inscricao = await InscricaoEvento.findByPk(id);
        if (!inscricao) {
            return res.status(404).json({ error: 'Inscrição não encontrada.' });
        }

        await inscricao.destroy();
        res.status(200).json({ message: 'Inscrição deletada com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Visualizar dados de uma inscrição específica
exports.visualizarDadosInscricao = async (req, res) => {
    try {
        const { id } = req.params;
        const inscricao = await InscricaoEvento.findByPk(id);
        if (!inscricao) {
            return res.status(404).json({ error: 'Inscrição não encontrada.' });
        }
        res.status(200).json(inscricao);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.medalhaEntregue = async (req, res) => {
    try {
        const { id } = req.params;
        const { medalhaEntregue } = req.body;

        const inscricao = await InscricaoEvento.findByPk(id);
        if (!inscricao) {
            return res.status(404).json({ error: 'Inscrição não encontrada.' });
        }

        inscricao.MEDALHA_ENTREGUE = medalhaEntregue; // Toggle the status
        await inscricao.save();

        res.status(200).json(inscricao);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
