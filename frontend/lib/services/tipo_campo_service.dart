part of 'env_services.dart';

class TipoCampoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get field types from the backend with optional filter parameter
  Future<List<TipoCampo>> getTiposCampo() async {
    String? token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/tipoCampo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> tipoCampoJson = jsonDecode(response.body);
      return tipoCampoJson.map((json) => TipoCampo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load TipoCampo');
    }
  }
}
