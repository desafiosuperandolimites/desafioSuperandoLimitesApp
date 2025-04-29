part of 'env_controllers.dart';

class GrupoController with ChangeNotifier {
  final GrupoService _groupService = GrupoService();
  List<Grupo> _groupList = [];
  Grupo? _selectedGrupo;

  List<Grupo> get groupList => _groupList;
  Grupo? get selectedGrupo => _selectedGrupo;

  Future<void> fetchGrupos({
    String? search,
    bool? filterActive,
  }) async {
    try {
      _groupList = await _groupService.getGrupos(
          search: search, filterActive: filterActive);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching groups: $e');
      }
    }
  }

  Future<void> fetchGrupoById(int id) async {
    try {
      _selectedGrupo = await _groupService.getGrupoById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching group: $e');
      }
    }
  }

  Future<void> createGrupo(BuildContext context, Grupo newGrupo) async {
    try {
      // Aqui, ao criar, o 'ID' não será enviado, pois o modelo 'toJson' ajusta isso
      await _groupService.createGrupo(newGrupo);
      await fetchGrupos();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating group: $e');
      }
      rethrow;
    }
  }

  Future<void> updateGrupo(
      BuildContext context, int id, Grupo updatedGrupo) async {
    try {
      await _groupService.updateGrupo(id, updatedGrupo); // Aqui o ID é enviado
      await fetchGrupos();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating group: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteGrupo(BuildContext context, int id) async {
    try {
      await _groupService.deleteGrupo(id);
      await fetchGrupos(); // Refresh the group list
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting group: $e');
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
