part of 'env_services.dart';

class GoogleAuthService {
  final String? baseUrl =
      dotenv.env['BASE_URL']; // Replace with your backend URL

  Future<Map<String, dynamic>> loginWithGoogle(String? idToken) async {
    print('Attempting to login with Google. ID Token: $idToken');
    final response = await http.post(
      Uri.parse('$baseUrl/auth/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': idToken}),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400){
      return jsonDecode(response.body);
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage = responseBody['error'] ?? 'Ocorreu um erro inesperado';
      print('Error: $errorMessage');
      throw errorMessage;
    }
  }
}