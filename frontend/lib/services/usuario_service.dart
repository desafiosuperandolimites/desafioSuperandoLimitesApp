part of 'env_services.dart';

class UsuarioService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Get users from the backend with optional search, sort, and filter parameters
  Future<List<Usuario>> getUsers({
    String? search,
    String? sortBy,
    String? sortDirection,
    bool? filtroAtivo,
    bool? filtroPagamento,
    bool? filtroCadastro,
    int? filtroGrupo,
  }) async {
    String? token = await _getToken();

    // Use Uri class to build the query parameters safely
    Uri uri = Uri.parse('$baseUrl/usuarios').replace(queryParameters: {
      if (search != null) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortDirection != null) 'sortDirection': sortDirection,
      if (filtroAtivo != null) 'filtroAtivo': filtroAtivo.toString(),
      if (filtroPagamento != null)
        'filtroPagamento': filtroPagamento.toString(),
      if (filtroCadastro != null) 'filtroCadastro': filtroCadastro.toString(),
      if (filtroGrupo != null && filtroGrupo != 1)
        'filtroGrupo': filtroGrupo.toString(),
    });

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  /// Get a user by their ID
  Future<Usuario> getUserById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return Usuario.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao carregar o usuário');
    }
  }

  Future<void> updateUser(BuildContext context, int id, Usuario user) async {
    String? token = await _getToken();
    if (kDebugMode) {
      print(user.toJson());
    }
    final response = await http.put(
      Uri.parse('$baseUrl/usuarios/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'Ocorreu um erro inesperado';
      throw errorMessage;
    }
  }

  /// Toggle user status (active/inactive)
  Future<void> toggleUserStatus(int id) async {
    String? token = await _getToken();
    final response = await http.patch(
      Uri.parse('$baseUrl/usuarios/$id/ativar-desativar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao ativar/desativar o usuário');
    }
  }

  /// Delete a user by their ID
  Future<void> deleteUser(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/usuarios/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar o usuário');
    }
  }

  /// Upload a user's profile picture
  Future<void> uploadProfilePicture(
      int id, http.MultipartFile imageFile) async {
    String? token = await _getToken();

    var uri = Uri.parse('$baseUrl/usuarios/$id/upload-profile-picture');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(imageFile);

    var response = await request.send();

    if (response.statusCode != 200) {
      throw Exception('Failed to upload profile picture');
    }
  }

  /// verifica se email existe no banco

  Future<bool> verifyEmail(String email) async {
    final uri = Uri.parse('$baseUrl/cadastro/verificar-email');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      // Assuming the response contains a key 'exists' with a boolean value
      return data['exists'] as bool;
    } else {
      throw Exception('Falha ao verificar o email');
    }
  }
}
