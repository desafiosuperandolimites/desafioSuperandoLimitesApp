part of 'env_controllers.dart';

class TipoCampoController with ChangeNotifier {
  final TipoCampoService _tipoCampoService = TipoCampoService();
  List<TipoCampo> _tipoCampoList = [];

  List<TipoCampo> get tipoCampoList => _tipoCampoList;

  Future<void> fetchTiposCampo() async {
    try {
      _tipoCampoList = await _tipoCampoService.getTiposCampo();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching TipoCampo: $e');
      }
    }
  }
}
