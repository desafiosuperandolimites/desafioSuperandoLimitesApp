const PerfilTipo = require('../models/perfisTipoModel');
const Usuario = require('../models/usuarioModel');
const GruposEvento = require('../models/gruposEventoModel');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');

exports.cadastroForm = async (req, res) => {
    try {
        const { NOME, EMAIL, SENHA, CONFIRMAR_SENHA, ID_GRUPO_EVENTO, ID_PERFIL_TIPO } = req.body;

        // Validate required fields
        if (!NOME || !EMAIL || !SENHA || !CONFIRMAR_SENHA || !ID_GRUPO_EVENTO) {
            return res.status(400).json({ error: 'Todos os campos obrigatórios devem ser preenchidos' });
        }

        if (SENHA.length < 8 ||
            !/[A-Z]/.test(SENHA) ||
            !/[a-z]/.test(SENHA) ||
            !/[0-9]/.test(SENHA) ||
            !/[\W_]/.test(SENHA)) {
            return res.status(400).json({
                error: 'A senha deve ter no mínimo 8 caracteres, incluindo letras maiúsculas, minúsculas, números e caracteres especiais.'
            });
        }

        // Validate password confirmation
        if (SENHA !== CONFIRMAR_SENHA) {
            return res.status(400).json({ error: 'As senhas não coincidem' });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(EMAIL)) {
            return res.status(400).json({ error: 'Email inválido' });
        }

        // Check if the email already exists in the database
        const existingUser = await Usuario.findOne({ where: { EMAIL } });
        if (existingUser) {
            return res.status(400).json({ error: 'O endereço de email já está em uso' });
        }

        // Find the associated group
        const grupo = await GruposEvento.findByPk(ID_GRUPO_EVENTO);
        if (!grupo) {
            return res.status(404).json({ error: 'Grupo de evento não encontrado.' });
        }

        // Find the associated perfil
        const perfil = await PerfilTipo.findByPk(ID_PERFIL_TIPO);
        if (!perfil) {
            return res.status(404).json({ error: 'Perfil não encontrado.' });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(SENHA, 10);

        // Create the user
        const newUser = await Usuario.create({
            NOME,
            EMAIL,
            SENHA: hashedPassword,
            ID_PERFIL_TIPO,
            ID_GRUPO_EVENTO // Associate the user with the group
        });

        // Increment QTD_USUARIOS in the associated group
        grupo.QTD_USUARIOS = (parseInt(grupo.QTD_USUARIOS) || 0) + 1;
        await grupo.save();

        res.status(201).json(newUser);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.adminCadastroForm = async (req, res) => {
    try {
        const currentUser = req.user;
        const { NOME, EMAIL, SENHA, CONFIRMAR_SENHA, ID_GRUPO_EVENTO, ID_PERFIL_TIPO } = req.body;

        // Validate required fields
        if (!NOME || !EMAIL || !SENHA || !CONFIRMAR_SENHA || !ID_GRUPO_EVENTO) {
            return res.status(400).json({ error: 'Todos os campos obrigatórios devem ser preenchidos' });
        }

        if (SENHA.length < 8 ||
            !/[A-Z]/.test(SENHA) ||
            !/[a-z]/.test(SENHA) ||
            !/[0-9]/.test(SENHA) ||
            !/[\W_]/.test(SENHA)) {
            return res.status(400).json({
                error: 'A senha deve ter no mínimo 8 caracteres, incluindo letras maiúsculas, minúsculas, números e caracteres especiais.'
            });
        }

        // Validate password confirmation
        if (SENHA !== CONFIRMAR_SENHA) {
            return res.status(400).json({ error: 'As senhas não coincidem' });
        }

        // Validate email format
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(EMAIL)) {
            return res.status(400).json({ error: 'Email inválido' });
        }

        // Check if the email already exists in the database
        const existingUser = await Usuario.findOne({ where: { EMAIL } });
        if (existingUser) {
            return res.status(400).json({ error: 'O endereço de email já está em uso' });
        }

        // Find the associated group
        const grupo = await GruposEvento.findByPk(ID_GRUPO_EVENTO);
        if (!grupo) {
            return res.status(404).json({ error: 'Grupo de evento não encontrado.' });
        }

        // Find the associated perfil
        const perfil = await PerfilTipo.findByPk(ID_PERFIL_TIPO);
        if (!perfil) {
            return res.status(404).json({ error: 'Perfil não encontrado.' });
        }

        // Hash the password
        const hashedPassword = await bcrypt.hash(SENHA, 10);

        // Create the user
        const newUser = await Usuario.create({
            NOME,
            EMAIL,
            SENHA: hashedPassword,
            ID_PERFIL_TIPO,
            ID_GRUPO_EVENTO, // Associate the user with the group
            SITUACAO: true // Ensure the user is marked as active
        });

        // Increment QTD_USUARIOS in the associated group
        grupo.QTD_USUARIOS = (parseInt(grupo.QTD_USUARIOS) || 0) + 1;
        await grupo.save();

        // Check if the current user's perfil tipo is 1 or 2
        if ((currentUser.ID_PERFIL_TIPO === 1 || currentUser.ID_PERFIL_TIPO === 2) && newUser.SITUACAO) {
            // Set up nodemailer transporter
            const transporter = nodemailer.createTransport({
                service: 'Gmail', // or use another email service
                auth: {
                    user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                    pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
                }
            });

            const mailOptions = {
                to: EMAIL,
                from: 'desafiosuperandolimites.contato@gmail.com',
                subject: 'Cadastro Realizado com Sucesso!',
                text: `Olá ${NOME},\n\n` +
                    `Seja bem-vindo ao App – Superando Limites!\n\n` +
                    `Estamos felizes em informar que seu cadastro foi realizado com sucesso pelo nosso administrador. Agora, você já pode acessar o aplicativo e começar a utilizar todas as funcionalidades.\n\n` +
                    `Aqui estão suas credenciais de acesso:\n` +
                    `  - Email: ${EMAIL}\n` +
                    `  - Senha: ${SENHA}\n\n` +
                    `Por segurança, recomendamos que você altere sua senha no primeiro acesso. Para acessar o aplicativo, basta utilizar suas credenciais acima.\n\n` +
                    `Precisa de ajuda?\n\n` +
                    `Se você tiver qualquer problema ou dúvida, entre em contato com nosso suporte:\n` +
                    `contato.desafiosuperandolimites@gmail.com | Telefone: (63) 99207-2064\n\n` +
                    `Obrigado por utilizar nossos serviços!\n\n` +
                    `Atenciosamente,\n` +
                    `Equipe Superando Limites`
            };

            // Fire-and-forget: dispara o envio do e-mail sem aguardar
            transporter.sendMail(mailOptions)
                .then(() => console.log(`Email sent to ${EMAIL}`))
                .catch(error => console.error(`Error sending email to ${EMAIL}:`, error));
        }

        res.status(201).json(newUser);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.verificarEmailExistente = async (req, res) => {
    try {
        // Retrieve the email from the request body (or req.query if preferred)
        const { email } = req.body;

        if (!email) {
            return res.status(400).json({ error: 'O email é obrigatório.' });
        }

        // Validate the email format using a regular expression
        const emailRegex = /^[^\s@]+@[^\s@]+.[^\s@]+$/;
        if (!emailRegex.test(email)) {
            return res.status(400).json({ error: 'Formato de email inválido.' });
        }

        // Check if a user with the provided email already exists
        const usuarioExistente = await Usuario.findOne({ where: { EMAIL: email } });

        if (usuarioExistente) {
            return res.status(200).json({
                exists: true,
                message: 'Email já cadastrado.'
            });
        } else {
            return res.status(200).json({
                exists: false,
                message: 'Email disponível para cadastro.'
            });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};