part of 'env_controllers.dart';

class InscricaoController with ChangeNotifier {
  final InscricaoService _inscricaoService = InscricaoService();
  InscricaoEvento? _inscricao;
  List<InscricaoEvento> _inscricaoList = [];
  bool entrega = false;

  List<InscricaoEvento> get inscricaoList => _inscricaoList;
  InscricaoEvento? get inscricao => _inscricao;

  // Criar uma nova inscrição
  Future<void> criarInscricao(
      BuildContext context, InscricaoEvento novaInscricao) async {
    try {
      await _inscricaoService.criarInscricao(novaInscricao);
      await fetchInscricoes(); // Atualiza a lista após a criação
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar inscrição: $e');
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar inscrição: $e')),
      );
    }
  }

  // Novo método: Recupera a inscrição específica de um usuário em um evento
  Future<void> getInscricaoByEvent({
    required int eventId,
  }) async {
    try {
      // Carregar inscrições do usuário
      _inscricaoList = await _inscricaoService.getInscricoesByEvento(eventId);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter a inscrição do usuário para o evento: $e');
      }
      return;
    }
  }

  // Novo método: Recupera a inscrição específica de um usuário em um evento
  Future<InscricaoEvento?> getInscricaoByUserAndEvent({
    required int userId,
    required int eventId,
  }) async {
    try {
      // Carregar inscrições do usuário
      _inscricaoList = await _inscricaoService.getInscricoesByUser(userId);

      // Procurar a inscrição do evento específico
      return _inscricaoList.firstWhere(
        (inscricao) => inscricao.idEvento == eventId,
        orElse: () => throw Exception(
            'Inscrição não encontrada'), // Lança uma exceção se não encontrar
      );
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter a inscrição do usuário para o evento: $e');
      }
      return null;
    }
  }

  // Buscar todas as inscrições com filtros
  Future<void> fetchInscricoes(
      {String? search, String? sortBy, String? sortDirection}) async {
    try {
      _inscricaoList = await _inscricaoService.getInscricoes(
        search: search,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar inscrições: $e');
      }
    }
  }

  // Buscar uma inscrição específica pelo ID
  Future<void> fetchInscricaoById(int id) async {
    try {
      _inscricao = await _inscricaoService.getInscricaoById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar inscrição: $e');
      }
    }
  }

  // Atualizar uma inscrição específica
  Future<void> atualizarInscricao(
      BuildContext context, int id, InscricaoEvento inscricaoAtualizada) async {
    try {
      await _inscricaoService.updateInscricao(id, inscricaoAtualizada);
      await fetchInscricaoById(id); // Atualiza a inscrição após a edição
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar inscrição: $e');
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Excluir uma inscrição
  Future<void> deletarInscricao(BuildContext context, int id) async {
    try {
      await _inscricaoService.deleteInscricao(id);
      await fetchInscricoes(); // Atualiza a lista após a exclusão
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao excluir inscrição: $e');
      }

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Limpar a inscrição do estado
  void clearInscricao() {
    _inscricao = null;
    notifyListeners();
  }

  // Verificar se o usuário já está inscrito em um evento específico
  Future<bool> isUserInscrito(
      {required int userId, required int eventId}) async {
    try {
      _inscricaoList = await _inscricaoService.getInscricoesByUser(userId);
      return _inscricaoList.any((inscricao) => inscricao.idEvento == eventId);
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao verificar inscrição: $e');
      }
      return false;
    }
  }

  // Obter o ID da inscrição de um usuário em um evento específico
  Future<int?> getInscricaoId(
      {required int userId, required int eventId}) async {
    try {
      _inscricaoList = await _inscricaoService.getInscricoesByUser(userId);
      var inscricao = _inscricaoList.firstWhere(
        (inscricao) => inscricao.idEvento == eventId,
      );
      return inscricao.id;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao obter ID de inscrição: $e');
      }
      return null;
    }
  }

  Future<InscricaoEvento?> medalhaEntregue(int id, bool status) async {
    try {
      final updatedInscricao =
          await _inscricaoService.medalhaEntregue(id, status);
      // Update the local inscricao if it matches the updated one
      if (_inscricao != null && _inscricao!.id == id) {
        _inscricao = updatedInscricao;
        notifyListeners();
      }
      return updatedInscricao;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar medalha: $e');
      }
      return null;
    }
  }
}
