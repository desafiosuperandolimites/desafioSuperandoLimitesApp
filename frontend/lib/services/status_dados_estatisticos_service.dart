part of 'env_services.dart';

class StatusDadosEstatisticosService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get status from the backend
  Future<List<StatusDadosEstatisticos>> getStatusDadosEstatisticos() async {
    String? token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/statusDadosEstatisticos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> statusJson = jsonDecode(response.body);
      return statusJson.map((json) => StatusDadosEstatisticos.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load StatusDadosEstatisticos');
    }
  }
}
