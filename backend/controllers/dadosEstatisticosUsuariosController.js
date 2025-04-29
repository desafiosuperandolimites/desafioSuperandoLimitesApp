const DadosEstatisticosUsuarios = require('../models/dadosEstatisticosUsuarios');
const Usuario = require('../models/usuarioModel');
const StatusDadosEstatisticos = require('../models/statusDadosEstatisticos');
const InscricaoEvento = require('../models/inscricaoEventoModel');
const Evento = require('../models/eventoModel');
const nodemailer = require('nodemailer');
const notificationService = require('../services/notificationService');


// Função para calcular o número da semana
function calculateWeekNumber(eventStartDate, activityDate) {
    const start = new Date(eventStartDate);
    const activity = new Date(activityDate);
    const diffInTime = activity.getTime() - start.getTime();
    const diffInDays = diffInTime / (1000 * 3600 * 24);
    return Math.floor(diffInDays / 7) + 1;
}

exports.adicionarDadosEstatisticos = async (req, res) => {
    try {
        const { ID_USUARIO_INSCRITO, ID_USUARIO_CADASTRA, ID_EVENTO, KM_PERCORRIDO, DATA_ATIVIDADE, FOTO } = req.body;

        // Validação dos campos
        if (!KM_PERCORRIDO || KM_PERCORRIDO <= 0) {
            return res.status(400).json({ error: 'Quilometragem deve ser um valor positivo.' });
        }

        if (!DATA_ATIVIDADE) {
            return res.status(400).json({ error: 'Data da atividade é obrigatória.' });
        }

        if (!FOTO) {
            return res.status(400).json({ error: 'Uma imagem comprovante é obrigatória.' });
        }

        const usuarioInscrito = await Usuario.findByPk(ID_USUARIO_INSCRITO);

        const admin = await Usuario.findByPk(1);


        // Validação do evento	
        const evento = await Evento.findByPk(ID_EVENTO);
        if (!evento) {
            return res.status(404).json({ error: 'Evento não encontrado.' });
        }

        const dataAtividade = new Date(DATA_ATIVIDADE);
        if (dataAtividade < evento.DATA_INICIO_DESAFIO || dataAtividade > evento.DATA_FIM_DESAFIO) {
            return res.status(400).json({ error: 'Data da atividade fora do período do evento.' });
        }

        // Calcula o número da semana
        const SEMANA = calculateWeekNumber(evento.DATA_INICIO_DESAFIO, DATA_ATIVIDADE);

        // Procura o status "Pendente de Aprovação"
        const status = await StatusDadosEstatisticos.findOne({
            where: { CHAVENOME: 'PENDENTE_APROVACAO' },
        });

        // Cria o registro
        const dados = await DadosEstatisticosUsuarios.create({
            ID_USUARIO_INSCRITO,
            ID_USUARIO_CADASTRA,
            ID_EVENTO,
            KM_PERCORRIDO,
            DATA_ATIVIDADE,
            FOTO,
            SEMANA,
            ID_STATUS_DADOS_ESTATISTICOS: status.ID,
        });

        const transporter = nodemailer.createTransport({
            service: 'Gmail', // or use another email service
            auth: {
                user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
            }
        });

        const formattedDate = new Date(DATA_ATIVIDADE).toLocaleDateString('pt-BR');

        const mailOptions = {
            to: admin.EMAIL,
            from: 'desafiosuperandolimites.contato@gmail.com',
            subject: 'Novo Envio de Km Percorrido para Aprovação',
            text: `Olá ${admin.NOME},\n\n` +
                `Informamos que o usuário ${usuarioInscrito.NOME} enviou novos dados de Km percorrido no evento ${evento.NOME} para sua revisão e aprovação. Seguem os detalhes:\n` +
                `  - Nome do Usuário: ${usuarioInscrito.NOME}\n` +
                `  - Desafio: ${evento.NOME}\n` +
                `  - Distância Percorrida: ${KM_PERCORRIDO}km\n` +
                `  - Data de Envio: ${formattedDate}\n` +
                `Para mais informações, acesse o aplicativo e verifique as atualizações. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
                `Precisa de ajuda?\n\n` +
                `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                `Obrigado por utilizar nossos serviços!\n\n` +
                `Atenciosamente,\n` +
                `Equipe Superando Limites`
        };

        // Fire-and-forget email for admin
        if (admin.SITUACAO) {
            transporter.sendMail(mailOptions)
                .then(info => console.log(`Email enviado para admin ${admin.EMAIL}`))
                .catch(err => console.error(`Erro ao enviar email para admin:`, err));
    
            const title_admin = 'Novo Envio de Km Percorrido';
            const body_admin = `Novo envio do usuário ${usuarioInscrito.NOME} de Km percorrido no evento ${evento.NOME} para sua aprovação! Acesse o app para verificar.`;
            // Fire-and-forget push notification to admin
            notificationService.sendNotificationToUser(admin.ID, title_admin, body_admin)
                .then(() => console.log("Push notification enviada para admin"))
                .catch(err => console.error("Erro ao enviar push notification para admin:", err));
        }

        // Send email and notification to the user
        const transporterAdmin = nodemailer.createTransport({
            service: 'Gmail', // or use another email service
            auth: {
                user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
            }
        });

        const mailOptionsAdmin = {
            to: usuarioInscrito.EMAIL,
            from: 'desafiosuperandolimites.contato@gmail.com',
            subject: 'Atualização no Status do Seu Envio de Km Percorrido',
            text: `Olá ${usuarioInscrito.NOME},\n\n` +
                `Temos uma atualização sobre o envio dos seus dados de Km percorrido no evento ${evento.NOME}. O status foi alterado e agora está como:\n` +
                `  - Status Atual: ${status.DESCRICAO}\n\n` +
                `Para mais informações, acesse o aplicativo e verifique as atualizações. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
                `Precisa de ajuda?\n\n` +
                `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                `Obrigado por utilizar nossos serviços!\n\n` +
                `Atenciosamente,\n` +
                `Equipe Superando Limites`
        };

        if (usuarioInscrito.SITUACAO) {
            transporterAdmin.sendMail(mailOptionsAdmin)
                .then(info => console.log(`Email enviado para usuário ${usuarioInscrito.EMAIL}`))
                .catch(err => console.error(`Erro ao enviar email para usuário:`, err));
    
            const title = 'Status de Dados de KM';
            const body = `A alteração do status de dados de Km  no evento ${evento.NOME} foi atualizado para: ${status.DESCRICAO}. Acesse o app para mais detalhes!`;
            notificationService.sendNotificationToUser(usuarioInscrito.ID, title, body)
                .then(() => console.log(`Push notification enviada para usuário ${usuarioInscrito.ID}`))
                .catch(err => console.error(`Erro ao enviar push notification para usuário:`, err));
        }

        res.status(201).json(dados);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.editarDadosEstatisticos = async (req, res) => {
    try {
        const { id } = req.params;
        const { ID_USUARIO_INSCRITO, KM_PERCORRIDO, DATA_ATIVIDADE, FOTO } = req.body;

        const usuarioInscrito = await Usuario.findByPk(ID_USUARIO_INSCRITO);

        const dados = await DadosEstatisticosUsuarios.findByPk(id);
        if (!dados) {
            return res.status(404).json({ error: 'Dados não encontrados.' });
        }

        const evento = await Evento.findByPk(dados.ID_EVENTO);

        // Verifica se o usuário tem permissão para editar os dados
        const statusPendenteCorrecao = await StatusDadosEstatisticos.findOne({
            where: { CHAVENOME: 'PENDENTE_CORRECAO' },
        });

        if (req.user.ID_PERFIL_TIPO === 3 && (
            dados.ID_USUARIO_INSCRITO !== ID_USUARIO_INSCRITO ||
            dados.ID_STATUS_DADOS_ESTATISTICOS !== statusPendenteCorrecao.ID
        )) {
            return res.status(403).json({ error: 'Você não tem permissão para editar estes dados.' });
        }

        // Atualiza os campos
        if (KM_PERCORRIDO) dados.KM_PERCORRIDO = KM_PERCORRIDO;
        if (DATA_ATIVIDADE) dados.DATA_ATIVIDADE = DATA_ATIVIDADE;
        if (FOTO) dados.FOTO = FOTO;

        // Reseta o status para "Pendente de Aprovação" se o usuário inscrito for diferente do usuário que aprova
        if (dados.ID_STATUS_DADOS_ESTATISTICOS === statusPendenteCorrecao.ID) {
            const statusPendenteAprovacao = await StatusDadosEstatisticos.findOne({
                where: { CHAVENOME: 'PENDENTE_APROVACAO' },
            });
            dados.ID_STATUS_DADOS_ESTATISTICOS = statusPendenteAprovacao.ID;

            dados.OBSERVACAO = null;

            const transporter = nodemailer.createTransport({
                service: 'Gmail', // or use another email service
                auth: {
                    user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                    pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
                }
            });

            const mailOptions = {
                to: usuarioInscrito.EMAIL,
                from: 'desafiosuperandolimites.contato@gmail.com',
                subject: 'Atualização no Status do Seu Envio de Km Percorrido',
                text: `Olá ${usuarioInscrito.NOME},\n\n` +
                    `Temos uma atualização sobre o envio dos seus dados de Km percorrido no evento ${evento.NOME}. O status foi alterado e agora está como:\n` +
                    `  - Status Atual: ${statusPendenteAprovacao.DESCRICAO}\n\n` +
                    `Para mais informações, acesse o aplicativo e verifique as atualizações. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
                    `Precisa de ajuda?\n\n` +
                    `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                    `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                    `Obrigado por utilizar nossos serviços!\n\n` +
                    `Atenciosamente,\n` +
                    `Equipe Superando Limites`
            };

            if (usuarioInscrito.SITUACAO) {
                transporter.sendMail(mailOptions)
                    .then(() => console.log(`Email enviado para ${usuarioInscrito.EMAIL}`))
                    .catch(error => console.error(`Erro ao enviar email:`, error));
    
                const title = 'Status de Dados de KM';
                const body = `A alteração do status de dados de Km  no evento ${evento.NOME} foi atualizado para: ${statusPendenteAprovacao.DESCRICAO}. Acesse o app para mais detalhes!`;
                notificationService.sendNotificationToUser(usuarioInscrito.ID, title, body)
                    .then(() => console.log(`Push notification enviada para usuário ${usuarioInscrito.ID}`))
                    .catch(error => console.error(`Erro ao enviar push notification:`, error));
            }
        }

        await dados.save();

        // Now check if the user has completed the challenge
        // Get the 'APROVADA' status
        const statusAprovada = await StatusDadosEstatisticos.findOne({
            where: { CHAVENOME: 'APROVADA' },
        });

        // Calculate total approved KM for the user in this event
        const totalKm = await DadosEstatisticosUsuarios.sum('KM_PERCORRIDO', {
            where: {
                ID_USUARIO_INSCRITO: usuarioInscrito.ID,
                ID_EVENTO: evento.ID,
                ID_STATUS_DADOS_ESTATISTICOS: statusAprovada.ID,
            },
        });

        // Get the user's registration (inscrição) to retrieve the goal (meta)
        const inscricao = await InscricaoEvento.findOne({
            where: {
                ID_USUARIO: usuarioInscrito.ID,
                ID_EVENTO: evento.ID,
            },
        });

        if (!inscricao) {
            console.error(
                `Inscrição not found for user ID ${usuarioInscrito.ID} and event ID ${evento.ID}`
            );
        } else {
            const meta = inscricao.META;

            // Check if the user has met or exceeded the goal and hasn't been notified yet
            if (totalKm >= meta && !inscricao.DESAFIO_CONCLUIDO) {
                // Send 'Desafio Concluído' notification
                const congratsTitle = 'Desafio Concluído';
                const congratsBody = `Parabéns, você concluiu o desafio ${evento.NOME}, compartilhe essa conquista!`;
                if (usuarioInscrito.SITUACAO) {
                    notificationService.sendNotificationToUser(usuarioInscrito.ID, congratsTitle, congratsBody);
                }
            }
        }

        res.status(200).json(dados);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.cancelarDadosEstatisticos = async (req, res) => {
    try {
        const { id } = req.params;
        const { OBSERVACAO } = req.body;

        const dados = await DadosEstatisticosUsuarios.findByPk(id);
        if (!dados) {
            return res.status(404).json({ error: 'Dados não encontrados.' });
        }

        const usuarioInscrito = await Usuario.findByPk(dados.ID_USUARIO_INSCRITO);

        const evento = await Evento.findByPk(dados.ID_EVENTO);



        // Atualiza o status para "Cancelado"
        const statusCancelado = await StatusDadosEstatisticos.findOne({
            where: { CHAVENOME: 'CANCELADO' },
        });

        dados.ID_STATUS_DADOS_ESTATISTICOS = statusCancelado.ID;
        dados.OBSERVACAO = OBSERVACAO;

        await dados.save();

        const transporter = nodemailer.createTransport({
            service: 'Gmail', // or use another email service
            auth: {
                user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
            }
        });

        const mailOptions = {
            to: usuarioInscrito.EMAIL,
            from: 'desafiosuperandolimites.contato@gmail.com',
            subject: 'Atualização no Status do Seu Envio de Km Percorrido',
            text: `Olá ${usuarioInscrito.NOME},\n\n` +
                `Temos uma atualização sobre o envio dos seus dados de Km percorrido no evento ${evento.NOME}. O status foi alterado e agora está como:\n` +
                `  - Status Atual: ${statusCancelado.DESCRICAO}\n\n` +
                `Para mais informações, acesse o aplicativo e verifique as atualizações. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
                `Precisa de ajuda?\n\n` +
                `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                `Obrigado por utilizar nossos serviços!\n\n` +
                `Atenciosamente,\n` +
                `Equipe Superando Limites`
        };

        if (usuarioInscrito.SITUACAO) {
            transporter.sendMail(mailOptions)
                .then(() => console.log(`Email enviado para ${usuarioInscrito.EMAIL}`))
                .catch(error => console.error(`Erro ao enviar email:`, error));
    
            const title = 'Status de Dados de KM';
            const body = `A alteração do status de dados de Km  no evento ${evento.NOME} foi atualizado para: ${statusCancelado.DESCRICAO}. Acesse o app para mais detalhes!`;
            notificationService.sendNotificationToUser(usuarioInscrito.ID, title, body)
                .then(() => console.log(`Push notification enviada para ${usuarioInscrito.ID}`))
                .catch(error => console.error(`Erro ao enviar push notification:`, error));
        }

        res.status(200).json(dados);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.aprovarDadosEstatisticos = async (req, res) => {
    try {
        const { id } = req.params;
        const { ID_USUARIO_APROVA } = req.body;

        const dados = await DadosEstatisticosUsuarios.findByPk(id);
        if (!dados) {
            return res.status(404).json({ error: 'Dados não encontrados.' });
        }

        const usuarioInscrito = await Usuario.findByPk(dados.ID_USUARIO_INSCRITO);


        // Atualiza o status para "Aprovada"
        const statusAprovada = await StatusDadosEstatisticos.findOne({
            where: { CHAVENOME: 'APROVADA' },
        });

        const evento = await Evento.findByPk(dados.ID_EVENTO);
        dados.SEMANA = calculateWeekNumber(evento.DATA_INICIO_DESAFIO, dados.DATA_ATIVIDADE);

        dados.ID_STATUS_DADOS_ESTATISTICOS = statusAprovada.ID;
        dados.ID_USUARIO_APROVA = ID_USUARIO_APROVA;
        await dados.save();

        const transporter = nodemailer.createTransport({
            service: 'Gmail', // or use another email service
            auth: {
                user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
            }
        });

        const mailOptions = {
            to: usuarioInscrito.EMAIL,
            from: 'desafiosuperandolimites.contato@gmail.com',
            subject: 'Atualização no Status do Seu Envio de Km Percorrido',
            text: `Olá ${usuarioInscrito.NOME},\n\n` +
                `Temos uma atualização sobre o envio dos seus dados de Km percorrido no evento ${evento.NOME}. O status foi alterado e agora está como:\n` +
                `  - Status Atual: ${statusAprovada.DESCRICAO}\n\n` +
                `Para mais informações, acesse o aplicativo e verifique as atualizações. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
                `Precisa de ajuda?\n\n` +
                `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                `Obrigado por utilizar nossos serviços!\n\n` +
                `Atenciosamente,\n` +
                `Equipe Superando Limites`
        };

        if (usuarioInscrito.SITUACAO) {
            transporter.sendMail(mailOptions)
                .then(() => console.log(`Email enviado para ${usuarioInscrito.EMAIL}`))
                .catch(error => console.error(`Erro ao enviar email:`, error));
    
            const title = 'Status de Dados de KM';
            const body = `A alteração do status de dados de Km  no evento ${evento.NOME} foi atualizado para: ${statusAprovada.DESCRICAO}. Acesse o app para mais detalhes!`;
            notificationService.sendNotificationToUser(usuarioInscrito.ID, title, body)
                .then(() => console.log(`Push notification enviada para ${usuarioInscrito.ID}`))
                .catch(error => console.error(`Erro ao enviar push notification:`, error));
        }

        // Calculate total KM for the user in this event
        const totalKm = await DadosEstatisticosUsuarios.sum('KM_PERCORRIDO', {
            where: {
                ID_USUARIO_INSCRITO: usuarioInscrito.ID,
                ID_EVENTO: evento.ID,
                ID_STATUS_DADOS_ESTATISTICOS: statusAprovada.ID, // Only approved data
            },
        });

        console.log(`Total KM for user ${usuarioInscrito.ID} in event ${evento.ID}: ${totalKm}`);

        // Get the user's registration (inscrição) to retrieve the goal (meta)
        const inscricao = await InscricaoEvento.findOne({
            where: {
                ID_USUARIO: usuarioInscrito.ID,
                ID_EVENTO: evento.ID,
            },
        });

        console.log(inscricao);

        if (!inscricao) {
            console.error(`Inscrição not found for user ID ${usuarioInscrito.ID} and event ID ${evento.ID}`);
        } else {
            const meta = inscricao.META;

            // Check if the user has met or exceeded the goal
            if (totalKm >= meta) {
                // Send 'Desafio Concluído' notification
                const congratsTitle = 'Desafio Concluído';
                const congratsBody = `Parabéns, você concluiu o desafio ${evento.NOME}, compartilhe essa conquista!`;
                if (usuarioInscrito.SITUACAO) {
                    notificationService.sendNotificationToUser(usuarioInscrito.ID, congratsTitle, congratsBody);
                }
            }
        }

        res.status(200).json(dados);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.rejeitarDadosEstatisticos = async (req, res) => {
    try {
        const { id } = req.params;
        const { ID_USUARIO_APROVA, OBSERVACAO } = req.body;

        const dados = await DadosEstatisticosUsuarios.findByPk(id);
        if (!dados) {
            return res.status(404).json({ error: 'Dados não encontrados.' });
        }

        const usuarioInscrito = await Usuario.findByPk(dados.ID_USUARIO_INSCRITO);

        const evento = await Evento.findByPk(dados.ID_EVENTO);

        // Atualiza o status para "PENDENTE_CORRECAO"
        const statusPendenteCorrecao = await StatusDadosEstatisticos.findOne({
            where: { CHAVENOME: 'PENDENTE_CORRECAO' },
        });

        dados.ID_USUARIO_APROVA = ID_USUARIO_APROVA;
        dados.ID_STATUS_DADOS_ESTATISTICOS = statusPendenteCorrecao.ID;
        dados.OBSERVACAO = OBSERVACAO;
        await dados.save();

        const transporter = nodemailer.createTransport({
            service: 'Gmail', // or use another email service
            auth: {
                user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
            }
        });

        const mailOptions = {
            to: usuarioInscrito.EMAIL,
            from: 'desafiosuperandolimites.contato@gmail.com',
            subject: 'Atualização no Status do Seu Envio de Km Percorrido',
            text: `Olá ${usuarioInscrito.NOME},\n\n` +
                `Temos uma atualização sobre o envio dos seus dados de Km percorrido no evento ${evento.NOME}. O status foi alterado e agora está como:\n` +
                `  - Status Atual: ${statusPendenteCorrecao.DESCRICAO}\n\n` +
                `Para mais informações, acesse o aplicativo e verifique as atualizações. Se precisar de ajuda ou tiver alguma dúvida, entre em contato com nosso suporte.\n\n` +
                `Precisa de ajuda?\n\n` +
                `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                `Obrigado por utilizar nossos serviços!\n\n` +
                `Atenciosamente,\n` +
                `Equipe Superando Limites`
        };

        if (usuarioInscrito.SITUACAO) {
            transporter.sendMail(mailOptions)
                .then(() => console.log(`Email enviado para ${usuarioInscrito.EMAIL}`))
                .catch(error => console.error(`Erro ao enviar email:`, error));
    
            // Send push notification to the user
            const title = 'Status de Dados de KM';
            const body = `A alteração do status de dados de Km  no evento ${evento.NOME} foi atualizado para: ${statusPendenteCorrecao.DESCRICAO}. Acesse o app para mais detalhes!`;
            notificationService.sendNotificationToUser(usuarioInscrito.ID, title, body)
                .then(() => console.log(`Push notification enviada para ${usuarioInscrito.ID}`))
                .catch(error => console.error(`Erro ao enviar push notification:`, error));
        }

        res.status(200).json(dados);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.registrarKMAdmin = async (req, res) => {
    try {
        const {
            ID_USUARIO_INSCRITO,
            ID_USUARIO_CADASTRA,
            ID_USUARIO_APROVA,
            ID_EVENTO,
            kmData,
        } = req.body;

        // Validate event
        const evento = await Evento.findByPk(ID_EVENTO);
        if (!evento) {
            return res.status(404).json({ error: 'Evento não encontrado.' });
        }

        // Get "Aprovada" status ID
        const statusAprovada = await StatusDadosEstatisticos.findOne({
            where: { CHAVENOME: 'APROVADA' },
        });

        // Loop through kmData and create records
        for (const entry of kmData) {
            const { KM_PERCORRIDO, SEMANA } = entry;

            // Calculate DATA_ATIVIDADE based on SEMANA
            const dataAtividade = new Date(
                evento.DATA_INICIO_DESAFIO.getTime() + (SEMANA - 1) * 7 * 24 * 60 * 60 * 1000
            );

            await DadosEstatisticosUsuarios.create({
                ID_USUARIO_INSCRITO,
                ID_USUARIO_CADASTRA,
                ID_USUARIO_APROVA,
                ID_EVENTO,
                KM_PERCORRIDO,
                DATA_ATIVIDADE: dataAtividade,
                SEMANA: SEMANA,
                ID_STATUS_DADOS_ESTATISTICOS: statusAprovada.ID,
            });
        }

        // **New Code Starts Here**

        const usuarioInscrito = await Usuario.findByPk(ID_USUARIO_INSCRITO);

        // Calculate total KM for the user in this event
        const totalKm = await DadosEstatisticosUsuarios.sum('KM_PERCORRIDO', {
            where: {
                ID_USUARIO_INSCRITO: ID_USUARIO_INSCRITO,
                ID_EVENTO: ID_EVENTO,
                ID_STATUS_DADOS_ESTATISTICOS: statusAprovada.ID, // Only approved data
            },
        });

        // Get the user's registration (inscrição) to retrieve the goal (meta)
        const inscricao = await InscricaoEvento.findOne({
            where: {
                ID_USUARIO: ID_USUARIO_INSCRITO,
                ID_EVENTO: ID_EVENTO,
            },
        });

        if (!inscricao) {
            console.error(`Inscrição not found for user ID ${ID_USUARIO_INSCRITO} and event ID ${ID_EVENTO}`);
        } else {
            const meta = inscricao.META;

            // Check if the user has met or exceeded the goal
            if (totalKm >= meta) {
                // Send 'Desafio Concluído' notification
                const congratsTitle = 'Desafio Concluído';
                const congratsBody = `Parabéns, você concluiu o desafio ${evento.NOME}, compartilhe essa conquista!`;
                if (usuarioInscrito.SITUACAO) {
                    notificationService.sendNotificationToUser(ID_USUARIO_INSCRITO, congratsTitle, congratsBody);
                }
            }
        }

        res.status(200).json({ message: 'Dados cadastrados com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.listarDadosEstatisticosUsuario = async (req, res) => {
    try {
        const { IdEvento, IdUsuarioInscrito } = req.query;

        const whereClause = {};
        if (IdEvento) whereClause.ID_EVENTO = IdEvento;
        if (IdUsuarioInscrito) whereClause.ID_USUARIO_INSCRITO = IdUsuarioInscrito;

        const dadosList = await DadosEstatisticosUsuarios.findAll({
            where: whereClause,
        });



        res.status(200).json(dadosList);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.listarDadosEstatisticosEvento = async (req, res) => {
    try {
        const { IdEvento } = req.query;

        const whereClause = {};
        if (IdEvento) whereClause.ID_EVENTO = IdEvento;

        const dadosList = await DadosEstatisticosUsuarios.findAll({
            where: whereClause,
        });



        res.status(200).json(dadosList);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}