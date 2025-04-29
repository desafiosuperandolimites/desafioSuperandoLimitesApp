part of 'env_services.dart';

class DuvidaEventoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get Duvidas Eventos from the backend with optional filter parameters
  Future<List<DuvidaEvento>> getDuvidasEventos({int? idUsuario}) async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/duvidasEventos').replace(queryParameters: {
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
      final List<dynamic> duvidaJson = jsonDecode(response.body);
      return duvidaJson.map((json) => DuvidaEvento.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Duvidas Eventos');
    }
  }

  Future<DuvidaEvento> getDuvidaEventoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/duvidasEventos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return DuvidaEvento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Duvida Evento');
    }
  }

  Future<DuvidaEvento> createDuvidaEvento(DuvidaEvento duvida) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/duvidasEventos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(duvida.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return DuvidaEvento.fromJson(responseBody);
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Erro inesperado ao criar dúvida.';
      throw Exception(errorMessage);
    }
  }

  Future<void> updateDuvidaEvento(int id, DuvidaEvento duvida) async {
    String? token = await _getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/duvidasEventos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(duvida.toJson()),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Duvida Evento updated successfully: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Error updating Duvida Evento: ${response.body}');
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

  Future<void> deleteDuvidaEvento(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/duvidasEventos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete Duvida Evento');
    }
  }

  Future<void> toggleDuvidaEventoStatus(int id) async {
    String? token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/duvidasEventos/$id/ativar-desativar'),
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
