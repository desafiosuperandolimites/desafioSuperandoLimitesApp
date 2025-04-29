part of 'env_services.dart';

class RespostaDuvidaService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get Respostas Duvida from the backend with optional filter parameters
  Future<List<RespostaDuvida>> getRespostasDuvida({int? idDuvidaEvento}) async {
    String? token = await _getToken();

    Uri uri =
        Uri.parse('$baseUrl/respDuvidasEventos').replace(queryParameters: {
      if (idDuvidaEvento != null) 'idDuvidaEvento': idDuvidaEvento.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> respostaJson = jsonDecode(response.body);
      return respostaJson.map((json) => RespostaDuvida.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load Respostas Duvida');
    }
  }

  Future<RespostaDuvida> getRespostaDuvidaById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/respDuvidasEventos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return RespostaDuvida.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Resposta Duvida');
    }
  }

  Future<RespostaDuvida> createRespostaDuvida(RespostaDuvida resposta) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/respDuvidasEventos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(resposta.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return RespostaDuvida.fromJson(responseBody);
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'An unexpected error occurred';
      throw Exception(errorMessage);
    }
  }

  Future<void> updateRespostaDuvida(int id, RespostaDuvida resposta) async {
    String? token = await _getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/respDuvidasEventos/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(resposta.toJson()),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Resposta Duvida updated successfully: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Error updating Resposta Duvida: ${response.body}');
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

  Future<void> deleteRespostaDuvida(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/respDuvidasEventos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete Resposta Duvida');
    }
  }
}
