part of 'env_services.dart';

class OpcaoCampoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get options from the backend with optional search parameter
  Future<List<OpcaoCampo>> getOpcoesCampo({int? idCamposPersonalizados}) async {
  String? token = await _getToken();

  Uri uri = Uri.parse('$baseUrl/opcoesCampo').replace(queryParameters: {
    if (idCamposPersonalizados != null) 'idCamposPersonalizados': idCamposPersonalizados.toString(),
  });

  final response = await http.get(
    uri,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> opcaoJson = jsonDecode(response.body);
    return opcaoJson.map((json) => OpcaoCampo.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load options');
  }
}

  Future<OpcaoCampo> getOpcaoCampoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/opcoesCampo/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return OpcaoCampo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load option');
    }
  }

  Future<void> createOpcaoCampo(OpcaoCampo opcao) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/opcoesCampo'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(opcao.toJson()),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'An unexpected error occurred';
      throw Exception(errorMessage);
    }
  }

  Future<void> updateOpcaoCampo(int id, OpcaoCampo opcao) async {
    String? token = await _getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/opcoesCampo/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(opcao.toJson()),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Option updated successfully: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Error updating option: ${response.body}');
        }
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['error'] ?? 'An unexpected error occurred';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Request error: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteOpcaoCampo(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/opcoesCampo/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete option');
    }
  }
}
