part of 'env_services.dart';

class EnderecoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<Endereco> getEnderecoById(int id) async {
    String? token = await AuthController().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/enderecos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Endereco.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar o endereço');
    }
  }

  Future<Endereco> getEnderecoByCep(String cep, int usuarioId) async {
    String? token = await AuthController().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/enderecos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'CEP': cep,
        'ID_USUARIO': usuarioId, // Pass the usuarioId to link the address
      }),
    );

    if (response.statusCode == 200) {
      // Handle the case where the address is fetched by CEP
      return Endereco.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 201) {
      // Handle the case where a new address is created
      return Endereco.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao buscar endereço pelo CEP');
    }
  }

  Future<Endereco> createEndereco({
    required String cep,
    required int usuarioId,
    required int? numero,
    String? complemento,
  }) async {
    String? token = await AuthController().getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/enderecos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'CEP': cep,
        'ID_USUARIO': usuarioId,
        'NUMERO': numero,
        'COMPLEMENTO': complemento, // Envia null caso não tenha valor
      }),
    );

    if (response.statusCode == 201) {
      return Endereco.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar o endereço');
    }
  }

  Future<void> updateEndereco(int id, Endereco endereco) async {
    String? token = await AuthController().getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/enderecos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(endereco.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar o endereço');
    }
  }

  Future<void> deleteEndereco(int id) async {
    String? token = await AuthController().getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/enderecos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao deletar o endereço');
    }
  }
}
