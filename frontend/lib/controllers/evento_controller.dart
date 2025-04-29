part of 'env_controllers.dart';

class EventoController with ChangeNotifier {
  final EventoService _eventoService = EventoService();
  Evento? _evento;

  Evento? get evento => _evento;

  List<Evento> _eventoList = [];

  List<Evento> get eventoList => _eventoList;

  Future<void> createEvento(BuildContext context, Evento newEvento) async {
    try {
      await _eventoService.createEvento(newEvento);
      await fetchEventos(); // Refresh the list after creation
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao criar evento: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> fetchEventosGrupoHomePage({
    String? search,
    String? sortBy,
    String? sortDirection,
    int? filtroGrupoHomePage,
    bool? isentoPagamento,
  }) async {
    try {
      _eventoList = await _eventoService.getEventosPorGrupo(
        search: search,
        sortBy: sortBy,
        sortDirection: sortDirection,
        filtroGrupoHomePage: filtroGrupoHomePage,
        isentoPagamento: isentoPagamento,
      );
      if (kDebugMode) {
        print("Eventos carregados do backend: ${eventoList.length}");
      }
      for (var evento in eventoList) {
        if (kDebugMode) {
          print("Evento: ${evento.nome}, Data Fim: ${evento.dataFimEvento}");
        }
      }
      notifyListeners(); // Notifica ouvintes para atualizar a UI
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar eventos: $e');
      }
    }
  }

  Future<void> fetchEventos({
    String? search,
    String? sortBy,
    String? sortDirection,
    bool? filtroAtivo,
    bool? isentoPagamento,
  }) async {
    try {
      _eventoList = await _eventoService.getEventos(
        search: search,
        sortBy: sortBy,
        sortDirection: sortDirection,
        filtroAtivo: filtroAtivo,
        isentoPagamento: isentoPagamento,
      );
      if (kDebugMode) {
        print("Eventos carregados do backend: ${eventoList.length}");
      }
      for (var evento in eventoList) {
        if (kDebugMode) {
          print("Evento: ${evento.nome}, Data Fim: ${evento.dataFimEvento}");
        }
      }
      notifyListeners(); // Notifica ouvintes para atualizar a UI
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar eventos: $e');
      }
    }
  }

  Future<void> fetchEventoById(int? id) async {
    try {
      _evento = await _eventoService.getEventoById(id!);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar evento: $e');
      }
    }
  }

  void clearEvento() {
    _evento = null;
    notifyListeners();
  }

  Future<void> updateEvento(
      BuildContext context, int id, Evento updatedEvento) async {
    try {
      await _eventoService.updateEvento(context, id, updatedEvento);
      await fetchEventoById(id); // Atualiza os dados do evento
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar evento: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }

      rethrow;
    }
  }

  Future<void> toggleEventoStatus(int id) async {
    try {
      await _eventoService.toggleEventoStatus(id);
      await fetchEventoById(id); // Atualiza o status do evento
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao alterar status do evento: $e');
      }
    }
  }

  Future<void> toggleEventoIsentoStatus(int id) async {
    try {
      await _eventoService.toggleEventoIsentoStatus(
          id); // Chama o serviço para alterar o status de isenção
      await fetchEventoById(id); // Atualiza os dados do evento após a alteração
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao alterar o status de pagamento isento do evento: $e');
      }
    }
  }

  Future<void> deleteEvento(int id) async {
    try {
      await _eventoService.deleteEvento(id); // Deleta o evento
      notifyListeners(); // Atualiza a lista de eventos
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao deletar evento: $e');
      }
    }
  }
}
