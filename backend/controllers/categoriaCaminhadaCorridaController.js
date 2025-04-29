// controllers/categoriaCaminhadaCorridaController.js

const CategoriaCaminhadaCorrida = require('../models/categoriaCaminhadaCorridaModel');

exports.createCategoria = async (req, res) => {
    try {
        const { DISTANCIA, CHAVE, DESCRICAO, SITUACAO } = req.body;
        // Validação simples para campos obrigatórios
        if (!DISTANCIA || !CHAVE || !DESCRICAO) {
            return res.status(400).json({ error: 'Todos os campos são obrigatórios (DISTANCIA, CHAVE, DESCRICAO).' });
        }

        const categoria = await CategoriaCaminhadaCorrida.create({
            DISTANCIA,
            CHAVE,
            DESCRICAO,
            SITUACAO: SITUACAO !== undefined ? SITUACAO : true  // Define o valor padrão como true, se não for fornecido
        });

        res.status(201).json(categoria);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.getCategorias = async (req, res) => {
    try {
        const categorias = await CategoriaCaminhadaCorrida.findAll();
        res.status(200).json(categorias);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
