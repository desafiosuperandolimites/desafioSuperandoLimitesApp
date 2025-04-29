part of 'env_controllers.dart';

class NotificacaoController extends ChangeNotifier {
  final NotificacaoService service = NotificacaoService();
  List<Notificacao> _allNotifications = [];
  List<Notificacao> filteredNotifications = [];
  bool showOnlyUnread = false;
  String searchQuery = '';

  int get unreadCount => _allNotifications.where((n) => !n.lida).length;

  Future<void> fetchNotificacoes(int userId) async {
    if (userId == 0) {
      _allNotifications = [];
      filteredNotifications = [];
      notifyListeners();
      return;
    }

    _allNotifications = await service.getNotificacoes(userId);
    // Ordena por mais recentes
    _allNotifications.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));
    applyFilters(); // Aplica filtros e notifica ouvintes
    notifyListeners(); // Notifica alterações para atualizar a barra de navegação
  }

  Future<void> initializeWithUser(UserController userController) async {
    if (userController.user != null) {
      final userId = userController.user!.id;
      await fetchNotificacoes(userId);
    }
  }

  void applyFilters() {
    List<Notificacao> result = _allNotifications;

    if (showOnlyUnread) {
      result = result.where((n) => !n.lida).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where((n) =>
              n.title.toLowerCase().contains(query) ||
              n.body.toLowerCase().contains(query))
          .toList();
    }

    // Sort by date desc again if needed
    result.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));

    filteredNotifications = result;
    notifyListeners();
  }

  void setShowOnlyUnread(bool value) {
    showOnlyUnread = value;
    applyFilters();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    applyFilters();
  }

  Future<void> marcarComoLida(int idNotificacao) async {
    await service.marcarComoLida(idNotificacao);
    // Update local state
    _allNotifications = _allNotifications.map((n) {
      if (n.id == idNotificacao) {
        return Notificacao(
          id: n.id,
          idUsuario: n.idUsuario,
          title: n.title,
          body: n.body,
          lida: true,
          criadoEm: n.criadoEm,
        );
      }
      return n;
    }).toList();
    applyFilters();
  }

  // Group notifications by "Esta semana" and then by "MMMM, yyyy"
  Map<String, List<Notificacao>> groupNotifications() {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    List<Notificacao> thisWeek = [];
    Map<String, List<Notificacao>> older = {};

    for (var n in filteredNotifications) {
      if (n.criadoEm.isAfter(oneWeekAgo)) {
        thisWeek.add(n);
      } else {
        final sectionTitle =
            DateFormat("MMMM, yyyy", 'pt_BR').format(n.criadoEm);
        older.putIfAbsent(sectionTitle, () => []);
        older[sectionTitle]!.add(n);
      }
    }

    Map<String, List<Notificacao>> grouped = {};
    if (thisWeek.isNotEmpty) {
      grouped["Esta semana"] = thisWeek;
    }

    var olderKeys = older.keys.toList();
    // Sort keys by date represented
    olderKeys.sort((a, b) {
      final aDate = DateFormat("MMMM, yyyy", 'pt_BR').parse(a);
      final bDate = DateFormat("MMMM, yyyy", 'pt_BR').parse(b);
      return bDate.compareTo(aDate); // Newer months first
    });

    for (var k in olderKeys) {
      // Capitalizing first letter if needed
      final capitalized = k[0].toUpperCase() + k.substring(1);
      grouped[capitalized] = older[k]!;
    }

    return grouped;
  }
}
