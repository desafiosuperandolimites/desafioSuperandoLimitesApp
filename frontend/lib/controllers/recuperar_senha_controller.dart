part of 'env_controllers.dart';

class RecuperarSenhaController {
  final RecuperarSenhaService _service = RecuperarSenhaService();

  Future<void> requestPasswordReset(BuildContext context, String email) async {
    final success = await _service.requestPasswordReset(context, email);
    if (!context.mounted) return;
    if (success) {
      Navigator.pushReplacementNamed(context, '/recuperar-enviado');
    } else {
    }
  }

  Future<void> resetPassword(String token, String senha, String confirmarsenha) async {
    final success = await _service.resetPassword(token, senha, confirmarsenha);
    if (success) {
      // Handle success (e.g., navigate to login page, show success message)
    } else {
      // Handle failure (e.g., show an error message)
    }
  }
}