part of 'env_services.dart';

class NotificacaoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  Future<List<Notificacao>> getNotificacoes(int userId) async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/notificacoes?ID_USUARIO=$userId');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> notificacaoJson = jsonDecode(response.body);
      if (kDebugMode) {
        print(notificacaoJson);
      }
      return notificacaoJson.map((json) => Notificacao.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> marcarComoLida(int id) async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/notificacoes/$id/lida');

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }
}
