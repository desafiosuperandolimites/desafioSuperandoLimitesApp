part of 'env_controllers.dart';

class PremiacaoController with ChangeNotifier {
  final PremiacaoService _premiacaoService = PremiacaoService();
  List<Premiacao> _premiacaoList = [];
  Premiacao? _selectedPremiacao;

  List<Premiacao> get premiacaoList => _premiacaoList;
  Premiacao? get selectedPremiacao => _selectedPremiacao;

  Future<void> fetchPremiacaos() async {
    try {
      _premiacaoList = await _premiacaoService.getPremiacaos();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching premiacaos: $e');
      }
    }
  }

  Future<void> fetchPremiacaoById(int id) async {
    try {
      _selectedPremiacao = await _premiacaoService.getPremiacaoById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching premiacao: $e');
      }
    }
  }

  Future<void> createPremiacao(
      BuildContext context, Premiacao newPremiacao) async {
    try {
      // Aqui, ao criar, o 'ID' não será enviado, pois o modelo 'toJson' ajusta isso
      await _premiacaoService.createPremiacao(newPremiacao);
      await fetchPremiacaos();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating group: $e');
      }
      rethrow;
    }
  }

  Future<void> updatePremiacao(
      BuildContext context, int id, Premiacao updatedPremiacao) async {
    try {
      await _premiacaoService.updatePremiacao(id, updatedPremiacao);
      await fetchPremiacaos(); // Atualiza a lista de prêmios
    } catch (e) {
      if (kDebugMode) {
        print('Error updating premiacao: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      rethrow;
    }
  }

  Future<void> deletePremiacao(BuildContext context, int id) async {
    try {
      await _premiacaoService.deletePremiacao(id);
      await fetchPremiacaos(); // Atualiza a lista de prêmios
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting premiacao: $e');
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
