part of 'env_controllers.dart';

class PagamentoInscricaoController with ChangeNotifier {
  final PagamentoInscricaoService _pagamentoService =
      PagamentoInscricaoService();
  List<PagamentoInscricao> _pagamentoList = [];
  PagamentoInscricao? _selectedPagamento;

  List<PagamentoInscricao> get pagamentoList => _pagamentoList;
  PagamentoInscricao? get selectedPagamento => _selectedPagamento;

  // Busca todos os pagamentos de inscrição com opções de busca e filtro
  Future<void> fetchPagamentosInscricoes() async {
    try {
      _pagamentoList = await _pagamentoService.getPagamentosInscricoes();
      if (kDebugMode) {
        print(_pagamentoList);
      }
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar pagamentos: $e');
      }
    }
  }

  Future<int?> fetchPagamentoPorInscricao(int idInscricaoEvento) async {
    try {
      PagamentoInscricao? pagamento =
          await _pagamentoService.getPagamentoByInscricao(idInscricaoEvento);

      if (pagamento != null) {
        return pagamento.idStatusPagamento; // Retorna o status do pagamento
      }
      return null; // Caso não encontre, retorna nulo
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar pagamento por inscrição: $e');
      }
      return null;
    }
  }

  // Busca pagamento de inscrição por ID e atualiza a seleção
  Future<void> fetchPagamentoInscricaoById(int idInscricaoEvento) async {
    try {
      _selectedPagamento =
          await _pagamentoService.getPagamentoInscricaoById(idInscricaoEvento);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar pagamento: $e');
      }
      _selectedPagamento = null;
    }
  }

  // Cria um novo pagamento de inscrição
  Future<PagamentoInscricao> createPagamentoInscricao(
      BuildContext context, PagamentoInscricao newPagamento) async {
    try {
      PagamentoInscricao createdPagamento =
          await _pagamentoService.createPagamentoInscricao(newPagamento);
      _pagamentoList.add(createdPagamento);
      notifyListeners();
      return createdPagamento;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar pagamento: $e');
      }
      rethrow;
    }
  }

  // Atualiza um pagamento de inscrição existente
  Future<void> updatePagamentoInscricao(
      BuildContext context, int id, PagamentoInscricao updatedPagamento) async {
    try {
      await _pagamentoService.updatePagamentoInscricao(id, updatedPagamento);
      await fetchPagamentosInscricoes();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar pagamento: $e');
      }
      rethrow;
    }
  }

  // Exclui um pagamento de inscrição
  Future<void> deletePagamentoInscricao(BuildContext context, int id) async {
    try {
      await _pagamentoService.deletePagamentoInscricao(id);
      await fetchPagamentosInscricoes();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao excluir pagamento: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      rethrow;
    }
  }

  // Aprova o pagamento e atualiza a lista
  Future<void> aprovarDadosPagamento(
      {required int id, required int idUsuarioAprova}) async {
    try {
      await _pagamentoService.aprovarDadosPagamento(
          id: id, idUsuarioAprova: idUsuarioAprova);
      await fetchPagamentosInscricoes(); // Atualiza a lista para refletir a mudança
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao aprovar dados: $e');
      }
    }
  }

  // Rejeita o pagamento com motivo e atualiza a lista
  Future<void> rejeitarDadosPagamento({
    required int id,
    required int idUsuarioAprova,
    required String motivo,
  }) async {
    try {
      await _pagamentoService.rejeitarDadosPagamento(
          id: id, idUsuarioAprova: idUsuarioAprova, motivo: motivo);
      await fetchPagamentosInscricoes(); // Atualiza a lista para refletir a mudança
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao rejeitar dados: $e');
      }
    }
  }
}
