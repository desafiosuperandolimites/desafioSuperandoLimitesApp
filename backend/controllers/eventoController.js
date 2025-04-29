const Evento = require('../models/eventoModel');
const ModalidadeEvento = require('../models/modalidadeModel');
const GrupoEvento = require('../models/gruposEventoModel');
const DuracaoEvento = require('../models/duracaoEventoModel');
const PremiacaoEvento = require('../models/premiacaoModel');
const Usuario = require('../models/usuarioModel');
const moment = require('moment-timezone');

// Listar todos os eventos do grupo do usuario logado.
exports.listarEventosGrupoHomePage = async (req, res) => {
    try {
        const { search, sortBy, sortDirection, filtroGrupoHomePage } = req.query;

        let whereClause = {};
        let orderClause = [['NOME', 'ASC']];

        // Search by name or descrição
        if (search) {
            whereClause = {
                ...whereClause,
                [Op.or]: [
                    { NOME: { [Op.iLike]: `%${search}%` } },

                ]
            };
        }

        if (filtroGrupoHomePage !== undefined) {
            whereClause.ID_GRUPO_EVENTO = filtroGrupoHomePage; // Convert string to boolean
        }


        // Sort by name or other fields
        if (sortBy) {
            orderClause = [[sortBy, sortDirection === 'desc' ? 'DESC' : 'ASC']];
        }

        const eventos = await Evento.findAll({
            where: whereClause,
            order: orderClause
        });

        res.status(200).json(eventos);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Listar todos os eventos com opções de busca, ordenação e filtragem
exports.listarEventos = async (req, res) => {
    try {
        const { search, sortBy, sortDirection, filtroAtivo } = req.query;

        let whereClause = {};
        let orderClause = [['NOME', 'ASC']];

        // Search by name or descrição
        if (search) {
            whereClause = {
                ...whereClause,
                [Op.or]: [
                    { NOME: { [Op.iLike]: `%${search}%` } },

                ]
            };
        }

        if (filtroAtivo !== undefined) {
            whereClause.SITUACAO = filtroAtivo === 'true'; // Convert string to boolean
        }


        // Sort by name or other fields
        if (sortBy) {
            orderClause = [[sortBy, sortDirection === 'desc' ? 'DESC' : 'ASC']];
        }

        const eventos = await Evento.findAll({
            where: whereClause,
            order: orderClause
        });

        res.status(200).json(eventos);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Criar um novo evento
exports.criarEvento = async (req, res) => {
    try {
        const { ID_MODALIDADE_EVENTO, ID_GRUPO_EVENTO, ID_PREMIACAO_EVENTO, ID_USUARIO, NOME, DESCRICAO, LOCAL, CAPA_EVENTO, DATA_INICIO_DESAFIO, DATA_FIM_DESAFIO, DATA_INICIO_INSCRICAO, DATA_FIM_INSCRICAO, ISENTO_PAGAMENTO, VALOR_EVENTO } = req.body;

        // Validate foreign key references
        const modalidade = await ModalidadeEvento.findByPk(ID_MODALIDADE_EVENTO);
        if (!modalidade) return res.status(400).json({ error: 'Modalidade de evento inválida.' });

        const grupo = await GrupoEvento.findByPk(ID_GRUPO_EVENTO);
        if (!grupo) return res.status(400).json({ error: 'Grupo de evento inválido.' });

        const premiacao = await PremiacaoEvento.findByPk(ID_PREMIACAO_EVENTO);
        if (!premiacao) return res.status(400).json({ error: 'Premiação do evento inválida.' });

        const usuario = await Usuario.findByPk(ID_USUARIO);
        if (!usuario) return res.status(400).json({ error: 'Usuário inválido.' });

        const adjustedInicioDesafio = moment(DATA_INICIO_DESAFIO).add(10, 'hours').toISOString();
        const adjustedFimDesafio = moment(DATA_FIM_DESAFIO).add(10, 'hours').toISOString();
        const adjustedInicioInscricao = moment(DATA_INICIO_INSCRICAO).add(10, 'hours').toISOString();
        const adjustedFimInscricao = moment(DATA_FIM_INSCRICAO).add(10, 'hours').toISOString();

        const novoEvento = await Evento.create({
            ID_MODALIDADE_EVENTO,
            ID_GRUPO_EVENTO,
            ID_PREMIACAO_EVENTO,
            ID_USUARIO,
            NOME,
            DESCRICAO,
            LOCAL,
            CAPA_EVENTO,
            DATA_INICIO_DESAFIO: adjustedInicioDesafio,
            DATA_FIM_DESAFIO: adjustedFimDesafio,
            DATA_INICIO_INSCRICAO: adjustedInicioInscricao,
            DATA_FIM_INSCRICAO: adjustedFimInscricao,
            ISENTO_PAGAMENTO,
            VALOR_EVENTO
        });

        res.status(201).json(novoEvento);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Editar informações de um evento específico
exports.editarEvento = async (req, res) => {
    try {
        const { id } = req.params;
        const { ID_MODALIDADE_EVENTO, ID_GRUPO_EVENTO, ID_PREMIACAO_EVENTO, ID_USUARIO, NOME, DESCRICAO, LOCAL, CAPA_EVENTO, DATA_INICIO_DESAFIO, DATA_FIM_DESAFIO, DATA_INICIO_INSCRICAO, DATA_FIM_INSCRICAO, SITUACAO, ISENTO_PAGAMENTO, VALOR_EVENTO } = req.body;

        const evento = await Evento.findByPk(id);
        if (!evento) {
            return res.status(404).json({ error: 'Evento não encontrado.' });
        }

        // Update fields
        evento.ID_MODALIDADE_EVENTO = ID_MODALIDADE_EVENTO ?? evento.ID_MODALIDADE_EVENTO;
        evento.ID_GRUPO_EVENTO = ID_GRUPO_EVENTO ?? evento.ID_GRUPO_EVENTO;
        evento.ID_PREMIACAO_EVENTO = ID_PREMIACAO_EVENTO ?? evento.ID_PREMIACAO_EVENTO;
        evento.ID_USUARIO = ID_USUARIO ?? evento.ID_USUARIO;
        evento.NOME = NOME ?? evento.NOME;
        evento.DESCRICAO = DESCRICAO ?? evento.DESCRICAO;
        evento.LOCAL = LOCAL ?? evento.LOCAL;
        evento.CAPA_EVENTO = CAPA_EVENTO ?? evento.CAPA_EVENTO;
        evento.DATA_INICIO_DESAFIO = DATA_INICIO_DESAFIO ?? evento.DATA_INICIO_DESAFIO;
        evento.DATA_FIM_DESAFIO = DATA_FIM_DESAFIO ?? evento.DATA_FIM_DESAFIO;
        evento.DATA_INICIO_INSCRICAO = DATA_INICIO_INSCRICAO ?? evento.DATA_INICIO_INSCRICAO;
        evento.DATA_FIM_INSCRICAO = DATA_FIM_INSCRICAO ?? evento.DATA_FIM_INSCRICAO;
        evento.SITUACAO = SITUACAO !== undefined ? SITUACAO : evento.SITUACAO;
        evento.ISENTO_PAGAMENTO = ISENTO_PAGAMENTO ?? evento.ISENTO_PAGAMENTO;
        evento.VALOR_EVENTO = VALOR_EVENTO ?? evento.VALOR_EVENTO;

        await evento.save();
        res.status(200).json(evento);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Excluir um evento específico
exports.deletarEvento = async (req, res) => {
    try {
        const { id } = req.params;

        const evento = await Evento.findByPk(id);
        if (!evento) {
            return res.status(404).json({ error: 'Evento não encontrado.' });
        }

        await evento.destroy();
        res.status(200).json({ message: 'Evento deletado com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Visualizar dados de um evento específico
exports.visualizarDadosEvento = async (req, res) => {
    try {
        const { id } = req.params;
        const evento = await Evento.findByPk(id);
        if (!evento) {
            return res.status(404).json({ error: 'Evento não encontrado.' });
        }
        res.status(200).json(evento);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Ativar/Inativar um evento
exports.ativarDesativarEvento = async (req, res) => {
    try {
        const { id } = req.params;

        const evento = await Evento.findByPk(id);
        if (!evento) {
            return res.status(404).json({ error: 'Evento não encontrado.' });
        }

        evento.SITUACAO = !evento.SITUACAO; // Toggle the status
        await evento.save();

        res.status(200).json({ message: `Evento ${evento.SITUACAO ? 'ativado' : 'inativado'} com sucesso.`, evento });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


// Ativar/Inativar um evento
exports.isentarNaoIsentarEvento = async (req, res) => {
    try {
        const { id } = req.params;

        const evento = await Evento.findByPk(id);
        if (!evento) {
            return res.status(404).json({ error: 'Evento não encontrado.' });
        }

        evento.ISENTO_PAGAMENTO = !evento.ISENTO_PAGAMENTO; // Toggle the status
        await evento.save();

        res.status(200).json({ message: `Evento ${evento.ISENTO_PAGAMENTO ? 'ativado' : 'inativado'} com sucesso.`, evento });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
