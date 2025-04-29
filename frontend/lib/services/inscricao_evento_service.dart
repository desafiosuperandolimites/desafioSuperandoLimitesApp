part of 'env_services.dart';

class InscricaoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

// Novo método para buscar inscrições por ID do evento
  Future<List<InscricaoEvento>> getInscricoesByEvento(int eventoId) async {
    String? token = await _getToken();

    // Construa a URL com o parâmetro eventoId
    final Uri uri = Uri.parse('$baseUrl/inscricoes/eventos')
        .replace(queryParameters: {'eventoId': eventoId.toString()});

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> inscricoesJson = jsonDecode(response.body);
      return inscricoesJson
          .map((json) => InscricaoEvento.fromJson(json))
          .toList();
    } else {
      if (kDebugMode) {
        print('Erro ao carregar inscrições: ${response.body}');
      }
      throw Exception('Falha ao carregar inscrições');
    }
  }

  // Novo método para buscar inscrições por ID do usuário
  Future<List<InscricaoEvento>> getInscricoesByUser(int userId) async {
    String? token = await _getToken();

    // Construa a URL com o parâmetro userId
    final Uri uri = Uri.parse('$baseUrl/inscricoes')
        .replace(queryParameters: {'userId': userId.toString()});

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> inscricoesJson = jsonDecode(response.body);
      return inscricoesJson
          .map((json) => InscricaoEvento.fromJson(json))
          .toList();
    } else {
      if (kDebugMode) {
        print('Erro ao carregar inscrições: ${response.body}');
      }
      throw Exception('Falha ao carregar inscrições');
    }
  }

  // Criar uma nova inscrição
  Future<void> criarInscricao(InscricaoEvento inscricao) async {
    String? token = await _getToken();
    try {
      // Cheque inscrições existentes
      final List<InscricaoEvento> inscricoesExistentes =
          await getInscricoesByUser(inscricao.idUsuario);
      bool inscritoNoEvento =
          inscricoesExistentes.any((i) => i.idEvento == inscricao.idEvento);

      if (inscritoNoEvento) {
        throw Exception('Você já possui uma inscrição neste evento.');
      }

      // Endpoint para criação
      Uri uri = Uri.parse('$baseUrl/inscricoes/criar');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(inscricao.toJson()),
      );

      if (response.statusCode != 201) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        String errorMessage = responseBody['error'] ?? 'Erro desconhecido';
        if (kDebugMode) {
          print(
              'Erro ao criar inscrição: ${response.statusCode} - ${response.body}');
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar inscrição: $e');
      }
      rethrow; // Propaga o erro para tratamento no controlador
    }
  }

  // Buscar todas as inscrições com parâmetros opcionais de filtro e ordenação
  Future<List<InscricaoEvento>> getInscricoes({
    String? search,
    String? sortBy,
    String? sortDirection,
  }) async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/inscricoes').replace(queryParameters: {
      if (search != null) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDirection != null) 'sortDirection': sortDirection,
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> inscricoesJson = jsonDecode(response.body);
      return inscricoesJson
          .map((json) => InscricaoEvento.fromJson(json))
          .toList();
    } else {
      throw Exception('Falha ao carregar inscrições');
    }
  }

  // Buscar uma inscrição específica pelo ID
  Future<InscricaoEvento> getInscricaoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/inscricoes/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return InscricaoEvento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar a inscrição');
    }
  }

  // Atualizar uma inscrição específica
  Future<void> updateInscricao(
      int id, InscricaoEvento inscricaoAtualizada) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/inscricoes/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(inscricaoAtualizada.toJson()),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw errorMessage;
    }
  }

  // Excluir uma inscrição específica
  Future<void> deleteInscricao(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/inscricoes/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar a inscrição');
    }
  }

  Future<InscricaoEvento> medalhaEntregue(int id, bool status) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/inscricoes/$id/entregue'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'medalhaEntregue': status}),
    );

    if (response.statusCode == 200) {
      return InscricaoEvento.fromJson(jsonDecode(response.body));
    } else {
      if (kDebugMode) {
        print(
            'Erro ao atualizar medalha: ${response.statusCode} - ${response.body}');
      }
      throw Exception('Falha ao atualizar a medalha');
    }
  }
}
