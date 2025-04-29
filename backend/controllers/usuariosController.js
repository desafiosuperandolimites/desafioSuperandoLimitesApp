const Usuario = require('../models/usuarioModel');
const { Op } = require('sequelize');
const SexoTipo = require('../models/sexoTipoModel');
const Endereco = require('../models/enderecoModel');
const EstadoCivilTipo = require('../models/estadosCivisTipoModel');
const GruposEvento = require('../models/gruposEventoModel');
const bcrypt = require('bcryptjs');

// Utility function to validate Brazilian phone numbers
const isValidPhoneNumber = (phoneNumber) => {
    const phoneRegex = /^\(?\d{2}\)?[\s-]?[\s9]?\d{4,5}-?\d{4}$/;
    return phoneRegex.test(phoneNumber);
};

// Listar todos os usuários com opções de busca, ordenação e filtragem
exports.listarUsuarios = async (req, res) => {
    try {
        const currentUser = req.user;

        // Ensure currentUser and required fields are defined
        if (!currentUser || !currentUser.ID || !currentUser.ID_PERFIL_TIPO) {
            return res.status(400).json({ error: 'Usuário não autenticado ou dados incompletos.' });
        }

        const { search, sortBy, sortDirection, filtroAtivo, filtroPagamento, filtroCadastro, filtroGrupo } = req.query;

        let whereClause = {};
        let orderClause = [['NOME', 'ASC']];

        // Handle Normal User (PERFIL_TIPO 3)
        if (currentUser.ID_PERFIL_TIPO === 3) {  // Normal User
            whereClause = { ID: currentUser.ID }; // Only list themselves
        }

        // Search by name or cpf
        if (search) {
            whereClause = {
                ...whereClause,
                [Op.or]: [
                    { NOME: { [Op.iLike]: `%${search}%` } },
                    { CPF: { [Op.iLike]: `%${search}%` } }
                ]
            };
        }

        if (filtroAtivo !== undefined) {
            whereClause.SITUACAO = filtroAtivo === 'true'; // Convert string to boolean
        }
        if (filtroPagamento !== undefined) {
            whereClause.PAGAMENTO_PENDENTE = filtroPagamento === 'true'; // Convert string to boolean
        }
        if (filtroCadastro !== undefined) {
            whereClause.CADASTRO_PENDENTE = filtroCadastro === 'true'; // Convert string to boolean
        }

        if (filtroGrupo !== undefined && filtroGrupo !== 1) {
            whereClause.ID_GRUPO_EVENTO = filtroGrupo;
        }

        // Sort by name or other fields
        if (sortBy) {
            orderClause = [[sortBy, sortDirection === 'desc' ? 'DESC' : 'ASC']];
        }

        const usuarios = await Usuario.findAll({
            where: whereClause,
            order: orderClause,
        });


        res.status(200).json(usuarios);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


// Editar informações de um usuário (all users can edit their own profile)
exports.editarUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            NOME,
            EMAIL,
            PROFISSAO,
            SENHA,
            CONFIRMAR_SENHA,
            CELULAR,
            CPF,
            RG,
            DATA_NASCIMENTO,
            FOTO_PERFIL,
            ID_GRUPO_EVENTO,
            SITUACAO,
            PESO,
            ALTURA,
            MATRICULA,
            PROBLEMA_SAUDE,
            ATIVIDADE_FISICA_REGULAR,
            APLICATIVO_ATIVIDADES,
            ID_SEXO_TIPO,
            ID_ESTADO_CIVIL_TIPO,
            ID_ENDERECO,
            ID_PERFIL_TIPO,
        } = req.body;

        const usuario = await Usuario.findByPk(id);
        if (!usuario) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        // Validate email format
        if (EMAIL) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(EMAIL)) {
                return res.status(400).json({ error: 'Email inválido' });
            }
            usuario.EMAIL = EMAIL;
        }

        // Validate and hash password if provided
        if (SENHA) {
            if (SENHA !== CONFIRMAR_SENHA) {
                return res.status(400).json({ error: 'As senhas não coincidem' });
            }
            usuario.SENHA = await bcrypt.hash(SENHA, 10);
        }

        // Validate phone number format
        if (CELULAR) {
            if (!isValidPhoneNumber(CELULAR)) {
                return res.status(400).json({ error: 'Número de celular inválido. Use o formato XX XXXXX-XXXX' });
            }
            usuario.CELULAR = CELULAR;
        }

        // Validate ID_SEXO_TIPO
        if (ID_SEXO_TIPO) {
            const sexoTipo = await SexoTipo.findByPk(ID_SEXO_TIPO);
            if (!sexoTipo) {
                return res.status(400).json({ error: 'Sexo inválido.' });
            }
            usuario.ID_SEXO_TIPO = ID_SEXO_TIPO;
        }

        // Validate ID_ESTADO_CIVIL_TIPO
        if (ID_ESTADO_CIVIL_TIPO) {
            const estadoCivilTipo = await EstadoCivilTipo.findByPk(ID_ESTADO_CIVIL_TIPO);
            if (!estadoCivilTipo) {
                return res.status(400).json({ error: 'Estado civil inválido.' });
            }
            usuario.ID_ESTADO_CIVIL_TIPO = ID_ESTADO_CIVIL_TIPO;
        }

        // Validate ID_ENDERECO
        if (ID_ENDERECO) {
            const endereco = await Endereco.findByPk(ID_ENDERECO);
            if (!endereco) {
                return res.status(400).json({ error: 'Endereço inválido.' });
            }
            usuario.ID_ENDERECO = ID_ENDERECO;
        }

        const oldGroupId = usuario.ID_GRUPO_EVENTO;

        // Update other fields except ID_PERFIL_TIPO
        usuario.NOME = NOME ?? usuario.NOME;
        usuario.CELULAR = CELULAR ?? usuario.CELULAR;
        usuario.PROFISSAO = PROFISSAO ?? usuario.PROFISSAO;
        usuario.EMAIL = EMAIL ?? usuario.EMAIL;
        usuario.CPF = CPF ?? usuario.CPF;
        usuario.RG = RG ?? usuario.RG;
        usuario.DATA_NASCIMENTO = DATA_NASCIMENTO ?? usuario.DATA_NASCIMENTO;
        usuario.FOTO_PERFIL = FOTO_PERFIL ?? usuario.FOTO_PERFIL;
        usuario.ID_GRUPO_EVENTO = ID_GRUPO_EVENTO ?? usuario.ID_GRUPO_EVENTO;
        usuario.SITUACAO = SITUACAO !== undefined ? SITUACAO : usuario.SITUACAO;
        usuario.PESO = PESO ?? usuario.PESO;
        usuario.ALTURA = ALTURA ?? usuario.ALTURA;
        usuario.MATRICULA = MATRICULA ?? usuario.MATRICULA;
        usuario.PROBLEMA_SAUDE = PROBLEMA_SAUDE ?? usuario.PROBLEMA_SAUDE;
        usuario.ATIVIDADE_FISICA_REGULAR = ATIVIDADE_FISICA_REGULAR ?? usuario.ATIVIDADE_FISICA_REGULAR;
        usuario.APLICATIVO_ATIVIDADES = APLICATIVO_ATIVIDADES ?? usuario.APLICATIVO_ATIVIDADES;
        usuario.ID_PERFIL_TIPO = ID_PERFIL_TIPO ?? usuario.ID_PERFIL_TIPO;

        await usuario.save();
        // After saving, check if the group has changed
        if (oldGroupId !== usuario.ID_GRUPO_EVENTO) {
            // Decrement QTD_USUARIOS in the old group
            if (oldGroupId) {
                const oldGroup = await GruposEvento.findByPk(oldGroupId);
                if (oldGroup) {
                    oldGroup.QTD_USUARIOS = Math.max((parseInt(oldGroup.QTD_USUARIOS) || 1) - 1, 0);
                    await oldGroup.save();
                }
            }

            // Increment QTD_USUARIOS in the new group
            if (usuario.ID_GRUPO_EVENTO) {
                const newGroup = await GruposEvento.findByPk(usuario.ID_GRUPO_EVENTO);
                if (newGroup) {
                    newGroup.QTD_USUARIOS = (parseInt(newGroup.QTD_USUARIOS) || 0) + 1;
                    await newGroup.save();
                }
            }
        }
        res.status(200).json(usuario);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Excluir conta do usuário específico 
exports.deletarUsuario = async (req, res) => {
    try {
        const currentUser = req.user;
        const { id } = req.params;

        // Ensure Normal User cannot delete other users
        if (currentUser.ID_PERFIL_TIPO === 3 && currentUser.ID !== parseInt(id)) {
            return res.status(403).json({ error: 'Você não tem permissão para deletar este usuário.' });
        }

        const usuario = await Usuario.findByPk(id);
        if (!usuario) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        if (usuario.ID_GRUPO_EVENTO) {
            const group = await GruposEvento.findByPk(usuario.ID_GRUPO_EVENTO);
            if (group) {
                group.QTD_USUARIOS = Math.max((parseInt(group.QTD_USUARIOS) || 1) - 1, 0);
                await group.save();
            }
        }

        await usuario.destroy();

        res.status(200).json({ message: 'Usuário deletado com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Visualizar dados de um usuário específico (no permission check needed here)
exports.visualizarDadosUsuario = async (req, res) => {
    try {
        const { id } = req.params;
        const usuario = await Usuario.findByPk(id);
        if (!usuario) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }
        res.status(200).json(usuario);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Ativar/Inativar um usuário (with permission check)
exports.ativarDesativarUsuario = async (req, res) => {
    try {
        const currentUser = req.user;
        const { id } = req.params;

        if (currentUser.ID_PERFIL_TIPO === 3 && currentUser.ID !== parseInt(id)) {
            return res.status(403).json({ error: 'Você não tem permissão para ativar/inativar este usuário.' });
        }

        const usuario = await Usuario.findByPk(id);
        if (!usuario) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        usuario.SITUACAO = !usuario.SITUACAO; // Toggle the status
        await usuario.save();

        res.status(200).json({ message: `Usuário ${usuario.SITUACAO ? 'ativado' : 'inativado'} com sucesso.`, usuario });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
