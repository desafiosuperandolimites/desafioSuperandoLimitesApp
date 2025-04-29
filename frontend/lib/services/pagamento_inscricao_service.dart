part of 'env_services.dart';

class PagamentoInscricaoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get pagamentos de inscrição with optional search and filter parameters
  Future<List<PagamentoInscricao>> getPagamentosInscricoes() async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/pagamentosInscricao');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> pagamentoJson = jsonDecode(response.body);
      return pagamentoJson
          .map((json) => PagamentoInscricao.fromJson(json))
          .toList();
    } else {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      String errorMessage =
          errorResponse['error'] ?? 'Failed to load pagamentos';
      throw Exception(errorMessage);
    }
  }

  // Get pagamento de inscrição by ID
  Future<PagamentoInscricao> getPagamentoInscricaoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/pagamentosInscricao/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return PagamentoInscricao.fromJson(jsonDecode(response.body));
    } else {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      String errorMessage =
          errorResponse['error'] ?? 'Failed to load pagamento';
      throw Exception(errorMessage);
    }
  }

  // Buscar pagamento por ID_INSCRICAO_EVENTO
  Future<PagamentoInscricao?> getPagamentoByInscricao(
      int idInscricaoEvento) async {
    String? token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/pagamentosInscricao/inscricao/$idInscricaoEvento'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return PagamentoInscricao.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      return null; // Pagamento não encontrado
    } else {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      String errorMessage =
          errorResponse['error'] ?? 'Erro ao buscar pagamento por inscrição';
      throw Exception(errorMessage);
    }
  }

  // Create new pagamento de inscrição
  Future<PagamentoInscricao> createPagamentoInscricao(
      PagamentoInscricao pagamento) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/pagamentoInscricao'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(pagamento.toJson()),
    );

    if (response.statusCode == 201) {
      // Parse the response and return the created CampoPersonalizado with ID
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      return PagamentoInscricao.fromJson(responseBody);
    } else {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Failed to create pagamento';
      throw Exception(errorMessage);
    }
  }

// Update pagamento de inscrição
  Future<void> updatePagamentoInscricao(
      int id, PagamentoInscricao pagamento) async {
    String? token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/pagamentoInscricao/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(pagamento.toJson()),
    );

    // Trate a resposta para imprimir erros
    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Failed to update pagamento';
      throw Exception(errorMessage);
    }
  }

  // Delete pagamento de inscrição
  Future<void> deletePagamentoInscricao(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/pagamentoInscricao/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      final Map<String, dynamic> errorResponse = jsonDecode(response.body);
      String errorMessage =
          errorResponse['error'] ?? 'Failed to delete pagamento';
      throw Exception(errorMessage);
    }
  }

// Aprovação no frontend
  Future<void> aprovarDadosPagamento({
    required int id,
    required int idUsuarioAprova,
  }) async {
    String? token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/pagamentoInscricao/$id/aprovar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ID_USUARIO_APROVA': idUsuarioAprova,
      }),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Failed to approve payment';
      throw Exception(errorMessage);
    }
  }

// Rejeição no frontend
  Future<void> rejeitarDadosPagamento({
    required int id,
    required int idUsuarioAprova,
    required String motivo,
  }) async {
    String? token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/pagamentoInscricao/$id/rejeitar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ID_USUARIO_APROVA': idUsuarioAprova,
        'MOTIVO': motivo,
      }),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage = responseBody['error'] ?? 'Failed to reject payment';
      throw Exception(errorMessage);
    }
  }
}
