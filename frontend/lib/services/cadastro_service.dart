part of 'env_services.dart';

class CadastroService {
  final String? baseUrl =
      dotenv.env['BASE_URL']; // Replace with your backend IP or localhost

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }


  Future<void> registerUser(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/cadastro/form'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      // Extract the error message from the response body
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw errorMessage;
    }
  }

  Future<void> adminRegisterUser(Map<String, dynamic> data) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/cadastro/form/admin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) {
      // Extract the error message from the response body
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw errorMessage;
    }
  }
}
