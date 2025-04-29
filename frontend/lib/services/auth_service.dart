part of 'env_services.dart';

class AuthService {
  final String? baseUrl =
      dotenv.env['BASE_URL']; // Replace with your backend URL

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'EMAIL': email, 'SENHA': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 400){
      return jsonDecode(response.body);
    }
     else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage = responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw errorMessage;
    }
  }

  Future<void> sendTokenToBackend(String? token) async {
    if (token == null) return;

    // Get the current user ID
    final UserController userController = UserController();
    await userController.fetchCurrentUser();
    final user = userController.user;
    final userId = user?.id;

    if (userId == null) return;

    // Send the token to your backend
    final response = await http.put(
      Uri.parse('$baseUrl/auth/update-fcm-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'fcmToken': token}),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw errorMessage;
    }
  }
}
