const Endereco = require('../models/enderecoModel');
const Usuario = require('../models/usuarioModel');
const axios = require('axios');

exports.adicionarEndereco = async (req, res) => {
  try {
    const { CEP, ID_USUARIO, NUMERO, COMPLEMENTO } = req.body;

    const complemento = COMPLEMENTO || null;

    console.log("Recebendo requisição com CEP:", CEP);

    // Busca detalhes do endereço pela API externa
    const response = await axios.get(`https://viacep.com.br/ws/${CEP}/json/`);
    if (response.data.erro) {
      console.log("Erro: CEP não encontrado na API externa.");
      return res.status(404).json({ error: 'CEP não encontrado.' });
    }

    const { uf, localidade, logradouro, bairro } = response.data;

    console.log("Dados recebidos da API externa:", response.data);

    // Retorna endereço básico se número ou complemento não forem fornecidos
    if (!NUMERO) {
      console.log("Número ou complemento ausentes, retornando endereço básico.");
      return res.status(200).json({
        CEP,
        UF: uf,
        CIDADE: localidade,
        LOGRADOURO: logradouro,
        BAIRRO: bairro,
      });
    }

    // Caso completo: cria ou retorna endereço existente
    let endereco = await Endereco.findOne({
      where: { CEP, NUMERO, COMPLEMENTO: complemento },
    });

    if (!endereco) {
      endereco = await Endereco.create({
        CEP,
        UF: uf,
        CIDADE: localidade,
        LOGRADOURO: logradouro,
        BAIRRO: bairro,
        COMPLEMENTO: complemento, // Permite null
        NUMERO,
      });
    }

    const usuario = await Usuario.findByPk(ID_USUARIO);
    usuario.ID_ENDERECO = endereco.ID;
    await usuario.save();

    console.log("Endereço salvo com sucesso:", endereco);
    return res.status(201).json(endereco);
  } catch (error) {
    console.error("Erro ao adicionar endereço:", error.message);
    return res.status(500).json({ error: error.message });
  }
};


exports.removerEndereco = async (req, res) => {
  try {
    const endereco = await Endereco.findByPk(req.params.id);
    if (!endereco) {
      return res.status(404).json({ error: 'Endereço não encontrado.' });
    }

    await endereco.destroy();
    return res.status(204).send();
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

exports.editarEndereco = async (req, res) => {
  try {
    console.log('Request Body:', req.body);
    const endereco = await Endereco.findByPk(req.params.id);
    if (!endereco) {
      console.log('Endereço não encontrado:', req.params.id);
      return res.status(404).json({ error: 'Endereço não encontrado.' });
    }
    console.log('Endereço antes da atualização:', endereco);
    await endereco.update(req.body);
    console.log('Endereço após a atualização:', endereco);
    return res.status(200).json(endereco);
  } catch (error) {
    console.error('Erro ao atualizar o endereço:', error.message);
    return res.status(500).json({ error: error.message });
  }
};


exports.visualizarEndereco = async (req, res) => {
  try {
    const endereco = await Endereco.findByPk(req.params.id);
    if (!endereco) {
      return res.status(404).json({ error: 'Endereço não encontrado.' });
    }
    return res.status(200).json(endereco);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};