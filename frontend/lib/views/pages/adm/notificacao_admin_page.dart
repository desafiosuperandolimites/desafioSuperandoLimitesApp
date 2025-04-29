part of '../../env.dart';

class NotificacaoAdminPage extends StatefulWidget {
  const NotificacaoAdminPage({super.key});

  @override
  State<NotificacaoAdminPage> createState() => _NotificacaoAdminPageState();
}

class _NotificacaoAdminPageState extends State<NotificacaoAdminPage> {
  late NotificacaoController _notificacaoController;
  int? userId;
  bool _isLoading = true;

  // If the user is logged in, send the new token to the backend
  final UserController userController = UserController();

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    await userController.fetchCurrentUser();
    final user = userController.user;
    userId = user?.id;

    await _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    _notificacaoController =
        Provider.of<NotificacaoController>(context, listen: false);
    await _notificacaoController.fetchNotificacoes(userId!);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<NotificacaoController>(context);
    final grouped = controller.groupNotifications();
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    double textScaleFactor = screenHeight < 668 ? 1 : 1.2;
    double scaleFactor = screenWidth / 430;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          SizedBox(
            height: screenHeight * 0.14,
            child: Stack(
              children: [
                // A semicircle or any header design you have
                CustomSemicirculo(
                  height: screenHeight * 0.12,
                  color: Colors.black,
                ),
                Positioned(
                  top: screenHeight * 0.04,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Notificações',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22 * textScaleFactor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Toggle for unread and search
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Row with toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text(
                      'Mostrar apenas itens não lidos',
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: controller.showOnlyUnread,
                        onChanged: (val) {
                          controller.setShowOnlyUnread(val);
                        },
                        activeColor: Colors.green,
                        inactiveTrackColor: Colors.grey,
                      ),
                    ),
                  ],
                ),

                // Search Bar
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onChanged: (val) => controller.setSearchQuery(val),
                        decoration: InputDecoration(
                          suffixIcon:
                              const Icon(Icons.search, color: Colors.grey),
                          labelText: 'Pesquisar',
                          labelStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.8),
                            fontSize: 18 * scaleFactor,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(8 * scaleFactor),
                            borderSide: BorderSide(
                                color: Colors.grey.withOpacity(0.5), width: 1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : grouped.isEmpty
                    ? const Center(
                        child: Text('Nenhuma notificação encontrada.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, sectionIndex) {
                          final sectionTitle =
                              grouped.keys.elementAt(sectionIndex);
                          final items = grouped[sectionTitle]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section Header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 8.0,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      sectionTitle,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              // Notifications in this section
                              Column(
                                children: items.map((n) {
                                  return GestureDetector(
                                    onTap: () async {
                                      if (!n.lida) {
                                        await controller.marcarComoLida(n.id);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                              color: Colors.grey, width: 0.5),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            n.title,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: n.lida
                                                  ? FontWeight.normal
                                                  : FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            n.body,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: n.lida
                                                  ? FontWeight.normal
                                                  : FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 3),
    );
  }
}
