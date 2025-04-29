part of 'env_controllers.dart';

class DadosEstatisticosUsuariosController with ChangeNotifier {
  final DadosEstatisticosUsuariosService _service =
      DadosEstatisticosUsuariosService();

  Future<void> adicionarDadosEstatisticos({
    required int idUsuarioInscrito,
    required int idUsuarioCadastra,
    required int idEvento,
    required double kmPercorrido,
    required DateTime dataAtividade,
    required String foto,
  }) async {
    try {
      await _service.adicionarDadosEstatisticos(
        idUsuarioInscrito: idUsuarioInscrito,
        idUsuarioCadastra: idUsuarioCadastra,
        idEvento: idEvento,
        kmPercorrido: kmPercorrido,
        dataAtividade: dataAtividade,
        foto: foto,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao adicionar dados: $e');
      }
    }
  }

  Future<void> editarDadosEstatisticos({
    required int id,
    required int idUsuarioInscrito,
    required double kmPercorrido,
    required DateTime dataAtividade,
    String? foto,
  }) async {
    try {
      await _service.editarDadosEstatisticos(
        id: id,
        idUsuarioInscrito: idUsuarioInscrito,
        kmPercorrido: kmPercorrido,
        dataAtividade: dataAtividade,
        foto: foto,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao editar dados: $e');
      }
    }
  }

  Future<void> cancelarDadosEstatisticos(int id, String observacao) async {
    try {
      await _service.cancelarDadosEstatisticos(id: id, observacao: observacao);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao cancelar dados: $e');
      }
    }
  }

  Future<List<int>> fetchAnosDisponiveis() async {
    try {
      // Busque todos os dados disponíveis
      List<DadosEstatisticosUsuarios> dadosList =
          await _service.getDadosEstatisticosEvento(
              idEvento: 0); // Use um ID genérico, se necessário

      // Extraia os anos únicos das datas de atividade
      List<int> anosDisponiveis = dadosList
          .map((dado) => DateTime.parse(dado.dataAtividade as String).year)
          .toSet()
          .toList();

      // Ordene os anos para consistência
      anosDisponiveis.sort();

      return anosDisponiveis;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar anos disponíveis: $e');
      }
      return [];
    }
  }

  Future<void> aprovarDadosEstatisticos({
    required int id,
    required int idUsuarioAprova,
  }) async {
    try {
      await _service.aprovarDadosEstatisticos(
        id: id,
        idUsuarioAprova: idUsuarioAprova,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao aprovar dados: $e');
      }
    }
  }

  Future<void> rejeitarDadosEstatisticos({
    required int id,
    required int idUsuarioAprova,
    required String observacao,
  }) async {
    try {
      await _service.rejeitarDadosEstatisticos(
        id: id,
        idUsuarioAprova: idUsuarioAprova,
        observacao: observacao,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao rejeitar dados: $e');
      }
    }
  }

  Future<void> registrarKMAdmin({
    required int idUsuarioInscrito,
    required int idUsuarioCadastra,
    required int idUsuarioAprova,
    required int idEvento,
    required List<Map<String, dynamic>> kmData,
  }) async {
    try {
      await _service.registrarKMAdmin(
        idUsuarioInscrito: idUsuarioInscrito,
        idUsuarioCadastra: idUsuarioCadastra,
        idUsuarioAprova: idUsuarioAprova,
        idEvento: idEvento,
        kmData: kmData,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao registrar KM: $e');
      }
      rethrow;
    }
  }

  Future<List<DadosEstatisticosUsuarios>> fetchDadosEstatisticosUsuario(
      int idEvento, int idUsuarioInscrito) async {
    try {
      List<DadosEstatisticosUsuarios> dadosList =
          await _service.getDadosEstatisticosUsuario(
        idEvento: idEvento,
        idUsuarioInscrito: idUsuarioInscrito,
      );
      return dadosList;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar dados: $e');
      }
      return [];
    }
  }

  Future<List<DadosEstatisticosUsuarios>> fetchDadosEstatisticosEvento(
      int idEvento) async {
    try {
      List<DadosEstatisticosUsuarios> dadosList =
          await _service.getDadosEstatisticosEvento(
        idEvento: idEvento,
      );
      return dadosList;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar dados: $e');
      }
      return [];
    }
  }
}
