part of '../env.dart';

class CustomBottomNavigationBarAdm extends StatefulWidget {
  final int currentIndex; // Pass the current index to the widget

  const CustomBottomNavigationBarAdm({
    super.key,
    required this.currentIndex,
  });

  @override
  CustomBottomNavigationBarAdmState createState() =>
      CustomBottomNavigationBarAdmState();
}

class CustomBottomNavigationBarAdmState
    extends State<CustomBottomNavigationBarAdm> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex; // Initialize with the passed index
  }

  // Function to navigate to the appropriate page
  void _onItemTapped(int index) {
    if (index != _selectedIndex) {
      setState(() {
        _selectedIndex = index;
      });

      // Navigate without stacking new pages
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePageAdm(),
            ),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const RelatorioGeralGraficosPage(),
            ),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminDuvidasPage(),
            ),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificacaoAdminPage(),
            ),
          );
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PerfilPageAdmin(),
            ),
          );
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificacaoController = Provider.of<NotificacaoController>(context);
    final int unreadCount =
        notificacaoController.unreadCount; // Obtém a contagem de não lidas

    return BottomNavigationBar(
      backgroundColor: Colors.black, // Background color for the admin nav bar
      selectedItemColor: const Color(0xFFFF7801), // Selected item color
      unselectedItemColor: Colors.white, // Unselected items (orange)
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped, // Update the selected index on tap
      currentIndex: _selectedIndex, // Highlight the selected icon
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.trending_up),
          label: 'Resultados',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.help_outline), // Use o ícone de "ajuda"
          label: 'Dúvidas',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            children: [
              const Icon(Icons.notifications),
              if (unreadCount >
                  0) // Exibe o contador apenas se houver notificações não lidas
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$unreadCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: 'Notificação',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
