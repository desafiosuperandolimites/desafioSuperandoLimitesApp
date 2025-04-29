part of 'env_controllers.dart';

class RespostaDuvidaController with ChangeNotifier {
  final RespostaDuvidaService _respostaService = RespostaDuvidaService();
  List<RespostaDuvida> _respostaList = [];
  RespostaDuvida? _selectedResposta;

  List<RespostaDuvida> get respostaList => _respostaList;
  RespostaDuvida? get selectedResposta => _selectedResposta;

  Future<void> fetchRespostasDuvida({int? idDuvidaEvento}) async {
    try {
      _respostaList = await _respostaService.getRespostasDuvida(
          idDuvidaEvento: idDuvidaEvento);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Respostas Duvida: $e');
      }
    }
  }

  Future<void> fetchRespostaDuvidaById(int id) async {
    try {
      _selectedResposta = await _respostaService.getRespostaDuvidaById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching Resposta Duvida: $e');
      }
    }
  }

  Future<RespostaDuvida> createRespostaDuvida(
      BuildContext context, RespostaDuvida newResposta) async {
    try {
      RespostaDuvida createdResposta =
          await _respostaService.createRespostaDuvida(newResposta);
      _respostaList.add(createdResposta);
      notifyListeners();
      return createdResposta;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating Resposta Duvida: $e');
      }
      rethrow;
    }
  }

  Future<void> updateRespostaDuvida(
      BuildContext context, int id, RespostaDuvida updatedResposta) async {
    try {
      await _respostaService.updateRespostaDuvida(id, updatedResposta);
      await fetchRespostasDuvida();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating Resposta Duvida: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteRespostaDuvida(BuildContext context, int id) async {
    try {
      await _respostaService.deleteRespostaDuvida(id);
      await fetchRespostasDuvida();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting Resposta Duvida: $e');
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
