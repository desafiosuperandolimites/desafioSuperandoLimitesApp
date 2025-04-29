part of 'env_services.dart';

class EventoService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  Future<void> createEvento(Evento evento) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/eventos/criar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(evento.toJson()),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw Exception(errorMessage);
    }
  }

  // Get eventos from the backend with optional search, sort, and filter parameters
  Future<List<Evento>> getEventos(
      {String? search,
      String? sortBy,
      String? sortDirection,
      bool? filtroAtivo,
      bool? isentoPagamento,
      int? filtroGrupoHomePage}) async {
    String? token = await _getToken();

    // Use Uri class to build the query parameters safely
    Uri uri = Uri.parse('$baseUrl/eventos').replace(queryParameters: {
      if (search != null) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDirection != null) 'sortDirection': sortDirection,
      if (filtroAtivo != null) 'filtroAtivo': filtroAtivo.toString(),
      if (filtroGrupoHomePage != null)
        'filtroGrupoHomePage': filtroGrupoHomePage.toString(),
      if (isentoPagamento != null) 'filtroAtivo': filtroAtivo.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventoJson = jsonDecode(response.body);
      return eventoJson.map((json) => Evento.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  }

// Get eventos from the backend with optional search, sort, and filter parameters
  Future<List<Evento>> getEventosPorGrupo(
      {String? search,
      String? sortBy,
      String? sortDirection,
      bool? filtroAtivo,
      bool? isentoPagamento,
      int? filtroGrupoHomePage}) async {
    String? token = await _getToken();

    // Use Uri class to build the query parameters safely
    Uri uri = Uri.parse('$baseUrl/eventos-por-grupo').replace(queryParameters: {
      if (search != null) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDirection != null) 'sortDirection': sortDirection,
      if (filtroAtivo != null) 'filtroAtivo': filtroAtivo.toString(),
      if (filtroGrupoHomePage != null)
        'filtroGrupoHomePage': filtroGrupoHomePage.toString(),
      if (isentoPagamento != null) 'filtroAtivo': filtroAtivo.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> eventoJson = jsonDecode(response.body);
      return eventoJson.map((json) => Evento.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  }

  Future<Evento> getEventoById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/eventos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Evento.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar o evento');
    }
  }

  Future<void> updateEvento(BuildContext context, int id, Evento evento) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/eventos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(evento.toJson()),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw errorMessage;
    }
  }

  Future<void> toggleEventoStatus(int id) async {
    String? token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/eventos/$id/ativar-desativar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao ativar/desativar o evento');
    }
  }

  Future<void> toggleEventoIsentoStatus(int id) async {
    String? token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/eventos/$id/isentar-nao-isentar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
          'Falha ao alterar o status de pagamento isento do evento');
    }
  }

  Future<void> deleteEvento(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/eventos/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar o evento');
    }
  }
}
