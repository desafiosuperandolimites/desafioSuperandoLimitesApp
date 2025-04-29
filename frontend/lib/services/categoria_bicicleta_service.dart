part of 'env_services.dart';

class CategoriaBicicletaService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<List<CategoriaBicicleta>> getCategorias() async {
    final String? token = await AuthController().getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/categoriasBicicleta'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> categoriaJson = json.decode(response.body);
      return categoriaJson
          .map((json) => CategoriaBicicleta.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load categorias de bicicleta');
    }
  }
}
