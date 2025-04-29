part of 'env_controllers.dart';

class GoogleAuthController {
  final AuthService _authService = AuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> loginWithGoogle(String? idToken, BuildContext context) async {
    try {
      print('Attempting to login with Google...');
      final response = await _googleAuthService.loginWithGoogle(idToken);
      print('Response received: $response');
      final jwtToken = response['token'];
      if (jwtToken != null) {
        print('JWT Token received: $jwtToken');
        await _storage.write(key: 'auth_token', value: jwtToken);
        if (!context.mounted) return;

        // Fetch and refresh the new user data
        print('Fetching and refreshing user data...');
        Provider.of<EnderecoController>(context, listen: false).clearEndereco();
        Provider.of<UserController>(context, listen: false).fetchCurrentUser();
      } else {
        print('Error received: ${response['error']}');
        throw response['error'];
      }
      final fcmToken = await _storage.read(key: 'fcm_token');
      print('FCM Token: $fcmToken');
      await _authService.sendTokenToBackend(fcmToken);
    } catch (e) {
      print('Exception caught: $e');
      throw e.toString();
    }
  }
}
