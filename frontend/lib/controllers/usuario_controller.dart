part of 'env_controllers.dart';

class UserController with ChangeNotifier {
  final UsuarioService _userService = UsuarioService();
  Usuario? _user;

  Usuario? get user => _user;

  List<Usuario> _userList = [];

  List<Usuario> get userList => _userList;

  /// Fetch all users with optional filters
  Future<void> fetchUsers({
    String? search,
    String? sortBy,
    String? sortDirection,
    bool? filtroAtivo,
    bool? filtroPagamento,
    bool? filtroCadastro,
    int? filtroGrupo,
  }) async {
    try {
      _userList = await _userService.getUsers(
        search: search,
        sortBy: sortBy,
        sortDirection: sortDirection,
        filtroGrupo: filtroGrupo,
        filtroAtivo: filtroAtivo,
        filtroPagamento: filtroPagamento,
        filtroCadastro: filtroCadastro,
      );
      notifyListeners(); // Notify listeners to update the UI
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching users: $e');
      }
    }
  }

  /// Fetch a specific user by ID
  Future<void> fetchUserById(int userId) async {
    try {
      _user = await _userService.getUserById(userId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
    }
  }

  /// Fetch the current user based on the decoded token
  Future<void> fetchCurrentUser() async {
    try {
      Map<String, dynamic>? decodedToken = await AuthController().decodeToken();
      if (decodedToken != null) {
        int userId = decodedToken['ID'];
        _user = await _userService.getUserById(userId);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
    }
  }

  /// Clear the current user data
  void clearUser() {
    _user = null;
    notifyListeners();
  }

  /// Update a user's information
  Future<void> updateUser(
      BuildContext context, int id, Usuario updatedUser) async {
    try {
      await _userService.updateUser(context, id, updatedUser);
      await fetchCurrentUser(); // Atualiza os dados do usuário
    } catch (e) {
      // Verifica se o erro contém a mensagem "Número de CPF já em uso"
      if (context.mounted) {
        String errorMessage = e.toString().contains('Numero de CPF ja em uso')
            ? 'Erro ao atualizar usuário. Por favor, tente novamente.'
            : 'Já existe um usuário com o mesmo CPF.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }

      rethrow;
    }
  }

  /// Toggle a user's active/inactive status
  Future<void> toggleUserStatus(int id) async {
    try {
      await _userService.toggleUserStatus(id);
      await fetchCurrentUser(); // Refresh the user data
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling user status: $e');
      }
    }
  }

  /// Delete a user by ID
  Future<void> deleteUser(int id) async {
    try {
      await _userService.deleteUser(id); // Delete the user data
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting user: $e');
      }
    }
  }

  Future<bool> verifyEmail(String email) async {
    try {
      return await _userService.verifyEmail(email);
    } catch (e) {
      if (kDebugMode) {
        print('Error verifying email: $e');
      }
      // Return false in case of an error, or you could rethrow the exception based on your use-case.
      return false;
    }
  }
}
