part of 'env_controllers.dart';

class DuvidaEventoController with ChangeNotifier {
  final DuvidaEventoService _duvidaService = DuvidaEventoService();
  List<DuvidaEvento> _duvidaList = [];
  DuvidaEvento? _selectedDuvida;

  List<DuvidaEvento> get duvidaList => _duvidaList;
  DuvidaEvento? get selectedDuvida => _selectedDuvida;

  Future<void> fetchDuvidasEventos({int? idUsuario}) async {
    try {
      _duvidaList =
          await _duvidaService.getDuvidasEventos(idUsuario: idUsuario);
      if (kDebugMode) {
        print('Dúvidas carregadas: $_duvidaList');
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Duvidas Eventos: $e');
      }
    }
  }

  Future<void> fetchDuvidaEventoById(int id) async {
    try {
      _selectedDuvida = await _duvidaService.getDuvidaEventoById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Duvida Evento: $e');
      }
    }
  }

  Future<DuvidaEvento> createDuvidaEvento(
      BuildContext context, DuvidaEvento newDuvida) async {
    try {
      DuvidaEvento createdDuvida = await _duvidaService
          .createDuvidaEvento(newDuvida); // Salva no backend
      _duvidaList.add(createdDuvida); // Adiciona à lista local
      notifyListeners();
      return createdDuvida;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar dúvida: $e');
      }
      rethrow;
    }
  }

  Future<void> updateDuvidaEvento(
      BuildContext context, int id, DuvidaEvento updatedDuvida) async {
    try {
      await _duvidaService.updateDuvidaEvento(id, updatedDuvida);
      await fetchDuvidasEventos();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Duvida Evento: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteDuvidaEvento(BuildContext context, int id) async {
    try {
      await _duvidaService.deleteDuvidaEvento(id);
      await fetchDuvidasEventos();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting Duvida Evento: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      rethrow;
    }
  }

  Future<void> toggleDuvidaEventoStatus(BuildContext context, int id) async {
    try {
      await _duvidaService.toggleDuvidaEventoStatus(id);
      await fetchDuvidasEventos();
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling Duvida Evento status: $e');
      }
      rethrow;
    }
  }
}
