part of 'env_services.dart';

class CategoriaCaminhadaCorridaService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<List<CategoriaCaminhadaCorrida>> getCategorias() async {
    final String? token = await AuthController().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/categoriasCaminhadaCorrida'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> categoriaJson = json.decode(response.body);
      return categoriaJson
          .map((json) => CategoriaCaminhadaCorrida.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load categorias de caminhada/corrida');
    }
  }
}
