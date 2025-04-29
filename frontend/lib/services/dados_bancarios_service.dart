part of 'env_services.dart';

class DadosBancariosService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    // Obter o token de autenticação
    return await AuthController().getToken();
  }

  // Criar dados bancários
  Future<void> createDadosBancarios(DadosBancarios dadosBancarios) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/dadosBancariosAdm'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dadosBancarios.toJson()),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw Exception(errorMessage);
    }
  }

  // Atualizar dados bancários
  Future<void> updateDadosBancarios(
      int id, DadosBancarios dadosBancarios) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/dadosBancariosAdm/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(dadosBancarios.toJson()),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw Exception(errorMessage);
    }
  }

  // Deletar dados bancários
  Future<void> deleteDadosBancarios(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/dadosBancariosAdm/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar os dados bancários');
    }
  }

  // Visualizar dados bancários por usuário
  Future<List<DadosBancarios>> getDadosBancariosByUsuario(int usuarioId) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/dadosBancariosAdm/$usuarioId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> dadosJson = jsonDecode(response.body);
      return dadosJson.map((json) => DadosBancarios.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar os dados bancários');
    }
  }
}
