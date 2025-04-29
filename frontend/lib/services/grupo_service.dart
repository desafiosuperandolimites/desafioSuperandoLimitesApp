part of 'env_services.dart';

class GrupoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get grupos from the backend with optional search, sort, and filter parameters
  Future<List<Grupo>> getGrupos({String? search, bool? filterActive}) async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/gruposEvento').replace(queryParameters: {
      if (search != null) 'search': search,
      if (filterActive != null) 'filterActive': filterActive.toString()
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> grupoJson = jsonDecode(response.body);
      return grupoJson.map((json) => Grupo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load grupos');
    }
  }

  Future<Grupo> getGrupoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/gruposEvento/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Grupo.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load grupo');
    }
  }

  Future<void> createGrupo(Grupo grupo) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/grupoEvento'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(grupo.toJson()),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'An unexpected error occurred';
      throw Exception(errorMessage);
    }
  }

  Future<void> updateGrupo(int id, Grupo grupo) async {
    String? token = await _getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/grupoEvento/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(grupo.toJson()),
      );

      // Verifica o status da resposta
      if (response.statusCode == 200) {
        // Log da resposta para debugging
        if (kDebugMode) {
          print('Grupo atualizado com sucesso: ${response.body}');
        }
      } else {
        // Captura o erro e mostra o corpo da resposta
        if (kDebugMode) {
          print('Erro na atualização do grupo: ${response.body}');
        }
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['error'] ?? 'Erro inesperado ocorreu';
        throw Exception(errorMessage);
      }
    } catch (e) {
      // Log completo do erro
      if (kDebugMode) {
        print('Erro na solicitação: $e');
      }
      rethrow; // Rethrow para manipulação posterior
    }
  }

  Future<void> deleteGrupo(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/grupoEvento/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete grupo');
    }
  }
}
