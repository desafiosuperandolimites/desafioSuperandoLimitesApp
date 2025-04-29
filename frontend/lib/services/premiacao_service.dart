part of 'env_services.dart';

class PremiacaoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get Premiacaos from the backend with optional search, sort, and filter parameters
  Future<List<Premiacao>> getPremiacaos() async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/premiacao');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> premiacaoJson = jsonDecode(response.body);
      if (kDebugMode) {
        print(premiacaoJson);
      }
      return premiacaoJson.map((json) => Premiacao.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Premiacaos');
    }
  }

  Future<Premiacao> getPremiacaoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/premiacao/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Premiacao.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar o prêmio');
    }
  }

  Future<void> createPremiacao(Premiacao premiacao) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/premiacao'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(premiacao.toJson()),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'An unexpected error occurred';
      throw Exception(errorMessage);
    }
  }

  Future<void> updatePremiacao(int id, Premiacao premiacao) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/premiacao/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(premiacao.toJson()),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw errorMessage;
    }
  }

  Future<void> deletePremiacao(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/premiacao/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar o prêmio');
    }
  }
}
