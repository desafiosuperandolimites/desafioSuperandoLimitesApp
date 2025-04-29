part of '../env.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int currentIndex; // Pass the current index to the widget

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
  });

  @override
  CustomBottomNavigationBarState createState() =>
      CustomBottomNavigationBarState();
}

class CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
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
              builder: (context) => const HomePage(),
            ),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const TodasDuvidasPage(),
            ),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificacaoPage(),
            ),
          );
          break;
        case 3:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PerfilPage(),
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
      backgroundColor: const Color(0xFFFF7801), // Cor de fundo da barra
      selectedItemColor: Colors.white, // Cor do item selecionado
      unselectedItemColor: Colors.black, // Cor dos itens não selecionados
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: _onItemTapped, // Atualiza o índice selecionado ao clicar
      currentIndex: _selectedIndex, // Destaca o ícone selecionado
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Início',
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
