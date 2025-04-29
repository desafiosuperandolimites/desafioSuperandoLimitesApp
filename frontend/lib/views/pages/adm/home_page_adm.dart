part of '../../env.dart';

class HomePageAdm extends StatelessWidget {
  const HomePageAdm({super.key});

  @override
  Widget build(BuildContext context) {
    // Screen dimensions
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<AdminOption> adminOptions = [
      AdminOption('Gestão\nUsuários', Icons.settings, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GestaoUsuarioPage()),
        );
      }),
      AdminOption('Gestão\nEventos', Icons.event, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GestaoEventosPage()),
        );
      }),
      AdminOption('Gestão\nGrupos', Icons.group, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GestaoGrupoPage()),
        );
      }),
      AdminOption('Gestão\nPagamentos', Icons.payment, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GestaoPagamentoPage()),
        );
      }),
      AdminOption('Gestão\nPremiações', Icons.emoji_events, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GestaoPremiacaoPage()),
        );
      }),
      AdminOption('Gestão\nNotícias', Icons.article, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GestaoNoticiaPage()),
        );
      }),
      AdminOption('Gestão\nde Km\'s', Icons.bar_chart, () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GestaoDeKms()),
        );
      }),
      AdminOption('Gestão\nDepoimentos', Icons.play_circle_fill, () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CadastrarDepoimentoPage()),
        );
      }),
      AdminOption('Relatório\nGeral', Icons.analytics, () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const RelatorioGeralGraficosPage()),
        );
      }),
    ];

    return Scaffold(
      bottomNavigationBar: const CustomBottomNavigationBarAdm(currentIndex: 0),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top part with semicircle and logo
          Stack(
            children: [
              // Black semicircle (replace with your custom widget or code)
              CustomSemicirculo(
                height: screenHeight * 0.15,
                color: Colors.black,
              ),
              // Positioned logo
              Positioned(
                top: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/image/Logo Principal Branco.png',
                    height: screenHeight * 0.1,
                    width: screenWidth * 0.5,
                  ),
                ),
              ),
            ],
          ),

          // Space between logo and grid
          SizedBox(height: screenHeight * 0.05),

          // Grid of management icons
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
              child: GridView.builder(
                itemCount: adminOptions.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 columns
                  crossAxisSpacing: screenWidth * 0.04,
                  mainAxisSpacing: screenHeight * 0.02,
                  childAspectRatio: 1.0, // Mantém os cards quadrados
                ),
                itemBuilder: (context, index) {
                  final option = adminOptions[index];
                  return _buildAdminCard(
                      option.title, option.icon, option.onPressed);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Method to build each admin card
  Widget _buildAdminCard(String title, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: constraints.maxWidth,
            height: constraints.maxWidth, // Mantém o formato quadrado
            padding: EdgeInsets.all(constraints.maxWidth * 0.05),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7801),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: constraints.maxWidth *
                      0.3, // Ajuste para manter a proporção
                  color: Colors.black,
                ),
                SizedBox(height: constraints.maxWidth * 0.05),
                SizedBox(
                  height: constraints.maxWidth * 0.4,
                  child: AutoSizeText(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    minFontSize: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Class to represent each admin option
class AdminOption {
  final String title;
  final IconData icon;
  final VoidCallback onPressed;

  AdminOption(this.title, this.icon, this.onPressed);
}
