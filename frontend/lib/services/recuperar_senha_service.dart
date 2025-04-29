part of 'env_services.dart';

class RecuperarSenhaService {
  final String? baseUrl =
      dotenv.env['BASE_URL']; // Replace with your backend URL

  Future<bool> requestPasswordReset(context, String email) async {
    final url = Uri.parse('$baseUrl/recuperar-senha');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Não foi possível enviar o e-mail de recuperação de senha. Verifique o endereço de e-mail e tente novamente.')),
      );
      return false;
    }
  }

  Future<bool> resetPassword(
      String token, String senha, String confirmarsenha) async {
    final url = Uri.parse('$baseUrl/recuperar-senha/$token');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'senha': senha, 'confirmarsenha': confirmarsenha}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      // Handle errors here
      return false;
    }
  }
}
