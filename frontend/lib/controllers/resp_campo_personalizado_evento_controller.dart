part of 'env_controllers.dart';

class RespCampoPersonalizadoEventoController with ChangeNotifier {
  final RespCampoPersonalizadoEventoService _respService =
      RespCampoPersonalizadoEventoService();
  List<RespCampoPersonalizadoEvento> _respList = [];
  RespCampoPersonalizadoEvento? _selectedResp;

  List<RespCampoPersonalizadoEvento> get respList => _respList;
  RespCampoPersonalizadoEvento? get selectedResp => _selectedResp;

  Future<void> fetchRespostasCamposPersonalizados({int? idUsuario}) async {
    try {
      _respList = await _respService.getRespostasCamposPersonalizados(
          idUsuario: idUsuario);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar respostas: $e');
      }
    }
  }

  Future<void> fetchRespostaCampoPersonalizadoById(int id) async {
    try {
      _selectedResp = await _respService.getRespostaCampoPersonalizadoById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar resposta: $e');
      }
    }
  }

  Future<void> saveRespostas({
    List<RespCampoPersonalizadoEvento>? respostasToCreate,
    List<RespCampoPersonalizadoEvento>? respostasToUpdate,
  }) async {
    if (respostasToCreate != null) {
      for (var resposta in respostasToCreate) {
        await _respService.createRespostaCampoPersonalizado(resposta);
      }
    }
    if (respostasToUpdate != null) {
      for (var resposta in respostasToUpdate) {
        await _respService.updateRespostaCampoPersonalizado(
            resposta.id!, resposta);
      }
    }
  }

  Future<void> createRespostaCampoPersonalizado(
      BuildContext context, RespCampoPersonalizadoEvento newResp) async {
    try {
      await _respService.createRespostaCampoPersonalizado(newResp);
      await fetchRespostasCamposPersonalizados();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar resposta: $e');
      }
      rethrow;
    }
  }

  Future<void> updateRespostaCampoPersonalizado(BuildContext context, int id,
      RespCampoPersonalizadoEvento updatedResp) async {
    try {
      await _respService.updateRespostaCampoPersonalizado(id, updatedResp);
      await fetchRespostasCamposPersonalizados();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar resposta: $e');
      }
      rethrow;
    }
  }

  Future<void> deleteRespostaCampoPersonalizado(
      BuildContext context, int id) async {
    try {
      await _respService.deleteRespostaCampoPersonalizado(id);
      await fetchRespostasCamposPersonalizados();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao deletar resposta: $e');
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
