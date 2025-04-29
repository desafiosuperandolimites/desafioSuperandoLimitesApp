part of 'env_services.dart';

class RespCampoPersonalizadoEventoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Obtém respostas do backend com parâmetro de pesquisa opcional
  Future<List<RespCampoPersonalizadoEvento>> getRespostasCamposPersonalizados(
      {int? idUsuario}) async {
    String? token = await _getToken();
    Uri uri = Uri.parse('$baseUrl/respostasCamposPersonalizados')
        .replace(queryParameters: {
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
      final List<dynamic> respJson = jsonDecode(response.body);
      return respJson
          .map((json) => RespCampoPersonalizadoEvento.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load responses');
    }
  }

  Future<RespCampoPersonalizadoEvento> getRespostaCampoPersonalizadoById(
      int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/respostasCamposPersonalizados/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return RespCampoPersonalizadoEvento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar resposta');
    }
  }

  Future<void> createRespostaCampoPersonalizado(
      RespCampoPersonalizadoEvento resp) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/respostasCamposPersonalizados'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(resp.toJson()),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw Exception(errorMessage);
    }
  }

  Future<void> updateRespostaCampoPersonalizado(
      int id, RespCampoPersonalizadoEvento resp) async {
    String? token = await _getToken();

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/respostasCamposPersonalizados/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(resp.toJson()),
      );

      if (response.statusCode == 200) {
        if (kDebugMode) {
          print('Resposta atualizada com sucesso: ${response.body}');
        }
      } else {
        if (kDebugMode) {
          print('Erro ao atualizar resposta: ${response.body}');
        }
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        String errorMessage =
            responseBody['error'] ?? 'Ocorreu um erro inesperado';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro na solicitação: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteRespostaCampoPersonalizado(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/respostasCamposPersonalizados/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao deletar resposta');
    }
  }
}
