part of 'env_services.dart';

class CampoPersonalizadoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get custom fields from the backend with optional search and filter parameters
  Future<List<CampoPersonalizado>> getCamposPersonalizados(
      {int? idGruposEvento}) async {
    String? token = await _getToken();

    Uri uri =
        Uri.parse('$baseUrl/camposPersonalizados').replace(queryParameters: {
      if (idGruposEvento != null) 'idGruposEvento': idGruposEvento.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> campoJson = jsonDecode(response.body);
      return campoJson
          .map((json) => CampoPersonalizado.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load Campos Personalizados');
    }
  }

  Future<CampoPersonalizado> getCampoPersonalizadoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/camposPersonalizados/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return CampoPersonalizado.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load custom field');
    }
  }

  Future<CampoPersonalizado> createCampoPersonalizado(
      CampoPersonalizado campo) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/camposPersonalizados'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(campo.toJson()),
    );

    if (response.statusCode == 201) {
      // Parse the response and return the created CampoPersonalizado with ID
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return CampoPersonalizado.fromJson(responseBody);
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'An unexpected error occurred';
      throw Exception(errorMessage);
    }
  }

  Future<void> updateCampoPersonalizado(
      int id, CampoPersonalizado campo) async {
    String? token = await _getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/camposPersonalizados/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(campo.toJson()),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Custom field updated successfully: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Error updating custom field: ${response.body}');
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

  Future<void> deleteCampoPersonalizado(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/camposPersonalizados/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete custom field');
    }
  }

  Future<void> toggleCampoPersonalizadoStatus(int id) async {
    String? token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/camposPersonalizados/$id/ativar-desativar'),
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
