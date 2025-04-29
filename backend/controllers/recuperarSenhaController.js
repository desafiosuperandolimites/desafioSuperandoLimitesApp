const crypto = require('crypto');
const nodemailer = require('nodemailer');
const Usuario = require('../models/usuarioModel');
const { Op } = require('sequelize');
const bcrypt = require('bcryptjs');

exports.emailRecuperarSenha = async (req, res) => {
    try {
        const { email } = req.body;

        // Find user by email
        const user = await Usuario.findOne({ where: { EMAIL: email } });
        if (!user) {
            return res.status(404).json({ error: 'Email não encontrado.' });
        }

        // Generate a secure token
        const token = crypto.randomBytes(32).toString('hex');
        const expires = new Date(Date.now() + 24 * 60 * 60 * 1000); // 24 hours from now

        // Save the token and expiration time to the user
        user.TOKEN_RECUPERAR_SENHA = token;
        user.EXPIRAR_TOKEN_RECUPERAR_SENHA = expires;
        await user.save();

        // Set up nodemailer transporter
        const transporter = nodemailer.createTransport({
            service: 'Gmail', // or use another email service
            auth: {
                user: 'desafiosuperandolimites.contato@gmail.com', // replace with your email
                pass: 'tiqt xqhv xjja zmlh'   // replace with your email password
            }
        });

        const ip = process.env.IP || 'localhost';
        const port = process.env.PORT || '3000';

        // Email content
        const resetUrl = `http://${ip}:${port}/api/recuperar-senha/${token}`;
        const mailOptions = {
            to: user.EMAIL,
            from: 'desafiosuperandolimites.contato@gmail.com',
            subject: 'Recuperação de Senha - Superando Limites',
            text: `Olá ${user.NOME},\n\n` +
                `Recebemos uma solicitação para redefinir a senha da sua conta. Se você fez essa solicitação, siga os passos abaixo para criar uma nova senha:\n\n` +
                `Clique no link abaixo para redefinir sua senha:\n${resetUrl}\n\n` +
                `Este link é válido por 24 horas. Se não for utilizado dentro desse período, será necessário solicitar novamente a recuperação de senha.\n\n` +
                `Siga as instruções na página de redefinição de senha:\n` +
                `- Insira uma nova senha que atenda aos seguintes critérios:\n` +
                `  - Mínimo de 8 caracteres.\n` +
                `  - Pelo menos uma letra maiúscula e uma minúscula.\n` +
                `  - Pelo menos um número.\n` +
                `  - Pelo menos um caractere especial (como @, #, $, etc.).\n\n` +
                `- Confirme sua nova senha e clique em "Redefinir".\n\n` +
                `Conclua o processo:\n` +
                `- Após redefinir sua senha, você poderá fazer login na sua conta normalmente.\n\n` +
                `Se você não solicitou a recuperação de senha, por favor, ignore este e-mail. Sua conta permanecerá segura.\n\n` +
                `Precisa de ajuda? Entre em contato com nosso suporte: suporte@superandolimites.com | Telefone: (XX) XXXX-XXXX\n\n` +
                `Obrigado por utilizar nossos serviços!\n\n` +
                `Atenciosamente,\n` +
                `Equipe Superando Limites`
        };

        // Send the email
        if (user.SITUACAO) {
            transporter.sendMail(mailOptions)
                .then(() => console.log(`Email enviado para ${user.EMAIL}`))
                .catch(error => console.error(`Erro ao enviar email:`, error));
        }

        res.status(200).json({ message: 'Email de recuperação de senha enviado com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.resetarSenha = async (req, res) => {
    try {
        const { token, senha, confirmarsenha } = req.body;

        // Find user by reset token and check expiration
        const user = await Usuario.findOne({
            where: {
                TOKEN_RECUPERAR_SENHA: token,
                EXPIRAR_TOKEN_RECUPERAR_SENHA: { [Op.gt]: Date.now() }
            }
        });

        if (!user) {
            return res.status(400).json({ error: 'Token inválido ou expirado.' });
        }

        // Validate the new senha
        if (senha !== confirmarsenha) {
            return res.status(400).json({ error: 'As senhas não coincidem.' });
        }

        // senha strength validation (optional)
        if (senha.length < 8 ||
            !/[A-Z]/.test(senha) ||
            !/[a-z]/.test(senha) ||
            !/[0-9]/.test(senha) ||
            !/[\W_]/.test(senha)) {
            return res.status(400).json({
                error: 'A senha deve ter no mínimo 8 caracteres, incluindo letras maiúsculas, minúsculas, números e caracteres especiais.'
            });
        }

        // Hash the new senha and save it
        user.SENHA = await bcrypt.hash(senha, 10);
        user.TOKEN_RECUPERAR_SENHA = null;
        user.EXPIRAR_TOKEN_RECUPERAR_SENHA = null;
        await user.save();

        res.status(200).json({ message: 'Senha redefinida com sucesso. Você pode fazer login com sua nova senha.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};