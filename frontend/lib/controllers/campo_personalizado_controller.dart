part of 'env_controllers.dart';

class CampoPersonalizadoController with ChangeNotifier {
  final CampoPersonalizadoService _campoService = CampoPersonalizadoService();
  List<CampoPersonalizado> _campoList = [];
  CampoPersonalizado? _selectedCampo;

  List<CampoPersonalizado> get campoList => _campoList;
  CampoPersonalizado? get selectedCampo => _selectedCampo;

  Future<void> fetchCamposPersonalizados({int? idGruposEvento}) async {
    try {
      _campoList = await _campoService.getCamposPersonalizados(idGruposEvento: idGruposEvento);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Campos Personalizados: $e');
      }
    }
  }

  Future<void> fetchCampoPersonalizadoById(int id) async {
    try {
      _selectedCampo = await _campoService.getCampoPersonalizadoById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching custom field: $e');
      }
    }
  }

  Future<CampoPersonalizado> createCampoPersonalizado(
      BuildContext context, CampoPersonalizado newCampo) async {
    try {
      CampoPersonalizado createdCampo = await _campoService.createCampoPersonalizado(newCampo);
      _campoList.add(createdCampo);
      notifyListeners();
      return createdCampo;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating custom field: $e');
      }
      rethrow;
    }
  }

  Future<void> updateCampoPersonalizado(
      BuildContext context, int id, CampoPersonalizado updatedCampo) async {
    try {
      await _campoService.updateCampoPersonalizado(id, updatedCampo);
      await fetchCamposPersonalizados();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating custom field: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteCampoPersonalizado(
      BuildContext context, int id) async {
    try {
      await _campoService.deleteCampoPersonalizado(id);
      await fetchCamposPersonalizados();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting custom field: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      rethrow;
    }
  }

  Future<void> toggleCampoPersonalizadoStatus(
      BuildContext context, int id) async {
    try {
      await _campoService.toggleCampoPersonalizadoStatus(id);
      await fetchCamposPersonalizados();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling custom field status: $e');
      }
      rethrow;
    }
  }
}
