part of 'env_controllers.dart';

class OpcaoCampoController with ChangeNotifier {
  final OpcaoCampoService _opcaoService = OpcaoCampoService();
  List<OpcaoCampo> _opcaoList = [];
  OpcaoCampo? _selectedOpcao;

  List<OpcaoCampo> get opcaoList => _opcaoList;
  OpcaoCampo? get selectedOpcao => _selectedOpcao;

  Future<void> fetchOpcoesCampo({int? idCamposPersonalizados}) async {
  try {
    _opcaoList = await _opcaoService.getOpcoesCampo(idCamposPersonalizados: idCamposPersonalizados);
    notifyListeners();
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching options: $e');
    }
  }
}

  Future<void> fetchOpcaoCampoById(int id) async {
    try {
      _selectedOpcao = await _opcaoService.getOpcaoCampoById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching option: $e');
      }
    }
  }

  Future<void> createOpcaoCampo(
      BuildContext context, OpcaoCampo newOpcao) async {
    try {
      await _opcaoService.createOpcaoCampo(newOpcao);
      await fetchOpcoesCampo();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating option: $e');
      }
      rethrow;
    }
  }

  Future<void> updateOpcaoCampo(
      BuildContext context, int id, OpcaoCampo updatedOpcao) async {
    try {
      await _opcaoService.updateOpcaoCampo(id, updatedOpcao);
      await fetchOpcoesCampo();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating option: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteOpcaoCampo(BuildContext context, int id) async {
    try {
      await _opcaoService.deleteOpcaoCampo(id);
      await fetchOpcoesCampo();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting option: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      rethrow;
    }
  }
}
