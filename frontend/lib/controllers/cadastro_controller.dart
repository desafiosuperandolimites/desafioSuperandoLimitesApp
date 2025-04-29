part of 'env_controllers.dart';

class CadastroController with ChangeNotifier {
  final CadastroService _cadastroService = CadastroService();

  // Return a boolean indicating success or failure
  Future<bool> register(
      BuildContext context, Map<String, dynamic> registrationData) async {
    try {
      // Try to register the user via the service
      await _cadastroService.registerUser(registrationData);

      // If successful, return true
      return true;
    } catch (e) {
      // Handle the error by printing in debug mode and showing an error message
      if (kDebugMode) {
        print(e);
      }

      if (!context.mounted) return false;

      // Show the error to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

      // If there was an error, return false
      return false;
    }
  }

  Future<bool> adminRegister(
      BuildContext context, Map<String, dynamic> registrationData) async {
    try {
      // Try to register the user via the service
      await _cadastroService.adminRegisterUser(registrationData);

      // If successful, return true
      return true;
    } catch (e) {
      // Handle the error by printing in debug mode and showing an error message
      if (kDebugMode) {
        print(e);
      }

      if (!context.mounted) return false;

      // Show the error to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );

      // If there was an error, return false
      return false;
    }
  }
}
