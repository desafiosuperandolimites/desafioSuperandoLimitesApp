part of 'env_services.dart';

class DadosEstatisticosUsuariosService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  Future<DadosEstatisticosUsuarios> adicionarDadosEstatisticos({
    required int idUsuarioInscrito,
    required int idUsuarioCadastra,
    required int idEvento,
    required double kmPercorrido,
    required DateTime dataAtividade,
    required String foto,
  }) async {
    String? token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/dadosEstatisticos'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ID_USUARIO_INSCRITO': idUsuarioInscrito,
        'ID_USUARIO_CADASTRA': idUsuarioCadastra,
        'ID_EVENTO': idEvento,
        'KM_PERCORRIDO': kmPercorrido,
        'DATA_ATIVIDADE': dataAtividade.toIso8601String(),
        'FOTO': foto,
      }),
    );

    if (response.statusCode == 201) {
      return DadosEstatisticosUsuarios.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao enviar dados.');
    }
  }

  Future<DadosEstatisticosUsuarios> editarDadosEstatisticos({
    required int id,
    required int idUsuarioInscrito,
    required double kmPercorrido,
    required DateTime dataAtividade,
    String? foto,
  }) async {
    String? token = await _getToken();

    final Map<String, dynamic> data = {
      'ID_USUARIO_INSCRITO': idUsuarioInscrito,
      'KM_PERCORRIDO': kmPercorrido,
      'DATA_ATIVIDADE': dataAtividade.toIso8601String(),
    };
    if (foto != null) {
      data['FOTO'] = foto;
    }

    final response = await http.put(
      Uri.parse('$baseUrl/dadosEstatisticos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return DadosEstatisticosUsuarios.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          'Falha ao editar dados. Status code: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<void> cancelarDadosEstatisticos({
    required int id,
    required String observacao,
  }) async {
    String? token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/dadosEstatisticos/cancelar/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'OBSERVACAO': observacao,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao cancelar dados.');
    }
  }

  Future<void> aprovarDadosEstatisticos({
    required int id,
    required int idUsuarioAprova,
  }) async {
    String? token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/dadosEstatisticos/aprovar/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ID_USUARIO_APROVA': idUsuarioAprova,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao aprovar dados.');
    }
  }

  Future<void> rejeitarDadosEstatisticos({
    required int id,
    required int idUsuarioAprova,
    required String observacao,
  }) async {
    String? token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/dadosEstatisticos/rejeitar/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ID_USUARIO_APROVA': idUsuarioAprova,
        'OBSERVACAO': observacao,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao rejeitar dados.');
    }
  }

  Future<void> registrarKMAdmin({
    required int idUsuarioInscrito,
    required int idUsuarioCadastra,
    required int idUsuarioAprova,
    required int idEvento,
    required List<Map<String, dynamic>> kmData,
  }) async {
    String? token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/dadosEstatisticos/admin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ID_USUARIO_INSCRITO': idUsuarioInscrito,
        'ID_USUARIO_CADASTRA': idUsuarioCadastra,
        'ID_USUARIO_APROVA': idUsuarioAprova,
        'ID_EVENTO': idEvento,
        'kmData': kmData,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao registrar KM.');
    }
  }

  Future<List<DadosEstatisticosUsuarios>> getDadosEstatisticosUsuario({
    required int idEvento,
    required int idUsuarioInscrito,
  }) async {
    String? token = await _getToken();

    final uri =
        Uri.parse('$baseUrl/dadosEstatisticos').replace(queryParameters: {
      'IdEvento': idEvento.toString(),
      'IdUsuarioInscrito': idUsuarioInscrito.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList
            .map((json) => DadosEstatisticosUsuarios.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Falha ao obter dados.');
    }
  }

  Future<List<DadosEstatisticosUsuarios>> getDadosEstatisticosEvento({
    required int idEvento,
  }) async {
    String? token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/dadosEstatisticos?IdEvento=$idEvento'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => DadosEstatisticosUsuarios.fromJson(json))
          .toList();
    } else {
      throw Exception('Falha ao obter dados.');
    }
  }
}
