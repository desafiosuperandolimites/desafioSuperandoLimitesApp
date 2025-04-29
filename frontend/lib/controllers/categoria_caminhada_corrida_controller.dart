part of 'env_controllers.dart';

class CategoriaCaminhadaCorridaController with ChangeNotifier {
  final CategoriaCaminhadaCorridaService _service =
      CategoriaCaminhadaCorridaService();
  List<CategoriaCaminhadaCorrida> _categorias = [];

  List<CategoriaCaminhadaCorrida> get categorias => _categorias;

  Future<void> fetchCategorias() async {
    try {
      _categorias = await _service.getCategorias();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar categorias de caminhada/corrida: $e');
      }
    }
  }
}
