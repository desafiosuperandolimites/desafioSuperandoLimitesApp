part of 'env_services.dart';

class StatusPagamentoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  // Método privado para obter o token de autenticação
  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Método para buscar os status de inscrição no backend
  Future<List<StatusPagamento>> getStatusPagamento() async {
    String? token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/statusPagamento'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> statusJson = jsonDecode(response.body);
      return statusJson.map((json) => StatusPagamento.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load StatusPagamento');
    }
  }
}
