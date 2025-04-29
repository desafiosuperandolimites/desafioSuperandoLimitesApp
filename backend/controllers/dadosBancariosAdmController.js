const DadosBancariosAdm = require('../models/dadosBancariosAdmModel');
const Usuario = require('../models/usuarioModel');

// Criar dados bancários
exports.criarDadosBancariosAdm = async (req, res) => {
    try {
        const { ID_USUARIO, AGENCIA, CONTA, TITULAR, BANCO, PIX, DATA_PAGAMENTO } = req.body;

        // Validação de campos obrigatórios
        if (!ID_USUARIO || !AGENCIA || !CONTA || !TITULAR || !BANCO) {
            return res.status(400).json({ error: 'Todos os campos obrigatórios devem ser preenchidos' });
        }

        // Verificar se o usuário existe
        const usuario = await Usuario.findByPk(ID_USUARIO);
        if (!usuario) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        // Criar os dados bancários
        const dadosBancariosAdm = await DadosBancariosAdm.create({
            ID_USUARIO,
            AGENCIA,
            CONTA,
            TITULAR,
            BANCO,
            PIX,
            DATA_PAGAMENTO,
            DATA_ATUALIZACAO: new Date()
        });

        res.status(201).json(dadosBancariosAdm);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Atualizar dados bancários
exports.atualizarDadosBancariosAdm = async (req, res) => {
    try {
        const { id } = req.params;
        const { AGENCIA, CONTA, TITULAR, BANCO, PIX, DATA_PAGAMENTO } = req.body;

        // Buscar os dados bancários pelo ID
        const dadosBancariosAdm = await DadosBancariosAdm.findByPk(id);
        if (!dadosBancariosAdm) {
            return res.status(404).json({ error: 'Dados bancários não encontrados.' });
        }

        // Atualizar os campos
        dadosBancariosAdm.AGENCIA = AGENCIA || dadosBancariosAdm.AGENCIA;
        dadosBancariosAdm.CONTA = CONTA || dadosBancariosAdm.CONTA;
        dadosBancariosAdm.TITULAR = TITULAR || dadosBancariosAdm.TITULAR;
        dadosBancariosAdm.BANCO = BANCO || dadosBancariosAdm.BANCO;
        dadosBancariosAdm.PIX = PIX || dadosBancariosAdm.PIX;
        dadosBancariosAdm.DATA_PAGAMENTO = DATA_PAGAMENTO || dadosBancariosAdm.DATA_PAGAMENTO;
        dadosBancariosAdm.DATA_ATUALIZACAO = new Date();

        await dadosBancariosAdm.save();

        res.status(200).json(dadosBancariosAdm);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Deletar dados bancários
exports.deletarDadosBancariosAdm = async (req, res) => {
    try {
        const { id } = req.params;

        // Buscar e deletar os dados bancários
        const dadosBancariosAdm = await DadosBancariosAdm.findByPk(id);
        if (!dadosBancariosAdm) {
            return res.status(404).json({ error: 'Dados bancários não encontrados.' });
        }

        await dadosBancariosAdm.destroy();

        res.status(200).json({ message: 'Dados bancários removidos com sucesso.' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Listar dados bancários por usuário
exports.visualizarDadosBancariosAdm = async (req, res) => {
    try {
        const { id } = req.params; // Modificado para pegar o ID da rota

        // Verificar se o usuário existe
        const usuario = await Usuario.findByPk(id); // Usando 'id' aqui
        if (!usuario) {
            return res.status(404).json({ error: 'Usuário não encontrado.' });
        }

        // Buscar dados bancários pelo ID do usuário
        const dadosBancariosAdm = await DadosBancariosAdm.findAll({
            where: { ID_USUARIO: id }
        });

        res.status(200).json(dadosBancariosAdm);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

