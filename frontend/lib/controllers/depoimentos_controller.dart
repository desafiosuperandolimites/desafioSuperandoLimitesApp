part of 'env_controllers.dart';

class DepoimentoController with ChangeNotifier {
  final DepoimentoService _depoimentoService = DepoimentoService();
  List<Depoimento> _depoimentoList = [];
  Depoimento? _selectedDepoimento;

  List<Depoimento> get depoimentoList => _depoimentoList;
  Depoimento? get selectedDepoimento => _selectedDepoimento;

  Future<List<Depoimento>> fetchDepoimentos({int? idUsuario}) async {
    try {
      _depoimentoList = await _depoimentoService.getDepoimentos(idUsuario: idUsuario);
      notifyListeners();
      return _depoimentoList; // Retorna a lista de depoimentos
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Depoimentos: $e');
      }
      rethrow; // Propaga o erro se necessário
    }
  }


  Future<void> fetchDepoimentoById(int id) async {
    try {
      _selectedDepoimento = await _depoimentoService.getDepoimentoById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Depoimento: $e');
      }
    }
  }

  Future<Depoimento> createDepoimento(BuildContext context, Depoimento newDepoimento) async {
    try {
      Depoimento createdDepoimento = await _depoimentoService.createDepoimento(newDepoimento);
      _depoimentoList.add(createdDepoimento);
      notifyListeners();
      return createdDepoimento;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating Depoimento: $e');
      }
      rethrow;
    }
  }

  Future<void> updateDepoimento(BuildContext context, int id, Depoimento updatedDepoimento) async {
    try {
      await _depoimentoService.updateDepoimento(id, updatedDepoimento);
      await fetchDepoimentos();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Depoimento: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteDepoimento(BuildContext context, int id) async {
    try {
      await _depoimentoService.deleteDepoimento(id);
      await fetchDepoimentos();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting Depoimento: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      rethrow;
    }
  }

  Future<void> toggleDepoimentoStatus(BuildContext context, int id) async {
    try {
      await _depoimentoService.toggleDepoimentoStatus(id);
      await fetchDepoimentos();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling Depoimento status: $e');
      }
      rethrow;
    }
  }
}
