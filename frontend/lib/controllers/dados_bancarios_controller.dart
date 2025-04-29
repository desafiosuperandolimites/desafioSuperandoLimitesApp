part of 'env_controllers.dart';

class DadosBancariosController {
  final DadosBancariosService _service = DadosBancariosService();
  DadosBancarios? _dadosBancarios;

  DadosBancarios? get dadosBancarios => _dadosBancarios;

  List<DadosBancarios> _dadosBancariosList = [];

  List<DadosBancarios> get dadosBancariosList => _dadosBancariosList;

  // Cria um novo registro de dados bancários
  Future<void> createDadosBancarios(DadosBancarios dadosBancarios) async {
    try {
      await _service.createDadosBancarios(dadosBancarios);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar dados bancários: $e');
      }
      rethrow;
    }
  }

  // Busca dados bancários por usuário
  Future<void> fetchDadosBancariosByUsuario(int usuarioId) async {
    try {
      _dadosBancariosList =
          await _service.getDadosBancariosByUsuario(usuarioId);
      if (_dadosBancariosList.isNotEmpty) {
        _dadosBancarios =
            _dadosBancariosList[0]; // Atribuindo o primeiro item da lista
      } else {
        _dadosBancarios = null; // Se a lista estiver vazia, define como null
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar dados bancários: $e');
      }
      rethrow;
    }
  }

  // Atualiza um registro existente de dados bancários
  Future<void> updateDadosBancarios(
      int id, DadosBancarios dadosBancarios) async {
    try {
      await _service.updateDadosBancarios(id, dadosBancarios);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar dados bancários: $e');
      }
      rethrow;
    }
  }

  // Deleta um registro de dados bancários
  Future<void> deleteDadosBancarios(int id) async {
    try {
      await _service.deleteDadosBancarios(id);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao deletar dados bancários: $e');
      }
      rethrow;
    }
  }
}
