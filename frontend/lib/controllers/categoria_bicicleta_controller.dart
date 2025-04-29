part of 'env_controllers.dart';

class CategoriaBicicletaController with ChangeNotifier {
  final CategoriaBicicletaService _service = CategoriaBicicletaService();
  List<CategoriaBicicleta> _categorias = [];

  List<CategoriaBicicleta> get categorias => _categorias;

  Future<void> fetchCategorias() async {
    try {
      _categorias = await _service.getCategorias();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar categorias de bicicleta: $e');
      }
    }
  }
}
