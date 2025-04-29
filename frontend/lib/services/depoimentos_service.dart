part of 'env_services.dart';

class DepoimentoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get Depoimentos from the backend with optional filter parameters
  Future<List<Depoimento>> getDepoimentos({int? idUsuario}) async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/depoimentos').replace(queryParameters: {
      if (idUsuario != null) 'idUsuario': idUsuario.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> depoimentoJson = jsonDecode(response.body);
      return depoimentoJson.map((json) => Depoimento.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Depoimentos');
    }
  }

  Future<Depoimento> getDepoimentoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/depoimentos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Depoimento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Depoimento');
    }
  }

  Future<Depoimento> createDepoimento(Depoimento depoimento) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/depoimentos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(depoimento.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return Depoimento.fromJson(responseBody);
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage = responseBody['error'] ?? 'An unexpected error occurred';
      throw Exception(errorMessage);
    }
  }

  Future<void> updateDepoimento(int id, Depoimento depoimento) async {
    String? token = await _getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/depoimentos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(depoimento.toJson()),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Depoimento updated successfully: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Error updating Depoimento: ${response.body}');
        }
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['error'] ?? 'An unexpected error occurred';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Request error: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteDepoimento(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/depoimentos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete Depoimento');
    }
  }

  Future<void> toggleDepoimentoStatus(int id) async {
    String? token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/depoimentos/$id/ativar-desativar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage = responseBody['error'] ?? 'Failed to toggle status';
      throw Exception(errorMessage);
    }
  }
}
