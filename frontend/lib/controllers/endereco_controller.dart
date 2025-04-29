part of 'env_controllers.dart';

class EnderecoController with ChangeNotifier {
  final EnderecoService _enderecoService = EnderecoService();
  Endereco? _endereco;

  Endereco? get endereco => _endereco;

  // Add this method to clear the current address
  void clearEndereco() {
    _endereco = null;
    notifyListeners();
  }

  Future<void> fetchEnderecoById(int? id) async {
    try {
      _endereco = await _enderecoService.getEnderecoById(id!);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching address: $e');
      }
    }
  }

  Future<Endereco?> fetchEnderecoByCep(String cep, int usuarioId) async {
    try {
      _endereco = await _enderecoService.getEnderecoByCep(cep, usuarioId);
      notifyListeners();
      return _endereco; // Retorne o endereço buscado
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching address by CEP: $e');
      }
      return null; // Retorne null em caso de erro
    }
  }

  Future<Endereco> createEndereco({
    required String cep,
    required int usuarioId,
    required int? numero,
    String? complemento, // Alterar para String?
  }) async {
    try {
      final endereco = await _enderecoService.createEndereco(
        cep: cep,
        usuarioId: usuarioId,
        numero: numero,
        complemento: complemento ?? '', // Enviar vazio ou null
      );
      _endereco = endereco;
      notifyListeners();
      return endereco;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating address: $e');
      }
      rethrow;
    }
  }

  Future<void> updateEndereco(int id, Endereco endereco) async {
    try {
      await _enderecoService.updateEndereco(id, endereco);
      _endereco = endereco; // Atualiza localmente para refletir a alteração
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating address: $e');
      }
    }
  }

  Future<void> deleteEndereco(int id) async {
    try {
      await _enderecoService.deleteEndereco(id);
      _endereco = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting address: $e');
      }
    }
  }
}
