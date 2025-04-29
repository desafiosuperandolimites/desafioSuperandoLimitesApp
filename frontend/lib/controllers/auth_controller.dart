part of 'env_controllers.dart'; // Import the AuthService

class AuthController {
  final AuthService _authService = AuthService(); // Instantiate the service
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      final response = await _authService.login(email, password);
      final token = response['token'];

      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);

        if (!context.mounted) return;

        // Fetch and refresh the new user data
        final userController =
            Provider.of<UserController>(context, listen: false);
        await userController.fetchCurrentUser();

        // Após obter o usuário, carregue as notificações
        final userId = userController.user?.id;
        if (userId != null) {
          final notificacaoController =
              Provider.of<NotificacaoController>(context, listen: false);
          await notificacaoController.fetchNotificacoes(userId);
        }
      } else {
        throw response['error'];
      }

      // Enviar token FCM para o backend
      final fcmToken = await _storage.read(key: 'fcm_token');
      await _authService.sendTokenToBackend(fcmToken);
    } catch (e) {
      throw e.toString();
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      // Step 1: Sign out from Firebase
      await FirebaseAuth.instance.signOut();
      print("User signed out from Firebase");

      // Step 2: Sign out from Google
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
        print("User signed out from Google");
      }

      // Step 3: Clear locally stored auth token
      await _storage.delete(key: 'auth_token');
      print("Auth token cleared");

      // Step 4: Clear user and address data
      if (!context.mounted) return;
      Provider.of<UserController>(context, listen: false).clearUser();
      Provider.of<EnderecoController>(context, listen: false).clearEndereco();

      // Step 5: Optionally navigate to login or home page
      Navigator.pushReplacementNamed(context, '/tipo-login');
    } catch (e) {
      print("Error during logout: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')),
      );
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<Map<String, dynamic>?> decodeToken() async {
    String? token = await getToken();
    if (token != null) {
      return JwtDecoder.decode(token);
    }
    return null;
  }
}
