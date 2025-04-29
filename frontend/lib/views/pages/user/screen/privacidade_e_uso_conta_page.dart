part of '../../../env.dart';

class PrivacidadeUsoContaPage extends StatefulWidget {
  final bool isAdminMode;
  const PrivacidadeUsoContaPage({super.key, this.isAdminMode = false});

  @override
  PrivacidadeUsoContaPageState createState() => PrivacidadeUsoContaPageState();
}

class PrivacidadeUsoContaPageState extends State<PrivacidadeUsoContaPage> {
  final UserController userController = UserController();
  late bool isAdminMode;

  // Pop-up de exclusão
  void _showDeleteConfirmationDialog() {
    final userController = Provider.of<UserController>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text('Excluir Conta'),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '\nVocê está prestes a excluir sua conta e com isso todos os dados serão apagados e você terá que criar uma nova conta se decidir voltar. Devido a isso talvez a melhor opção seja somente inativar a conta na tela anterior.',
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o diálogo
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      userController.deleteUser(userController.user!.id);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Conta Excluída'),
                            content: const Text(
                                'A conta juntamente com todos os dados relacionados a ela foi excluída.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Fecha o diálogo
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SobreAppPage(),
                                    ),
                                  );
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Confirmar Exclusão',
                      style: TextStyle(color: Colors.black45),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Pop-up de inativação
  void _showInativaConfirmationDialog() {
    final userController = Provider.of<UserController>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
            child: Text('Inativar Conta'),
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '\nVocê está prestes a inativar sua conta e com isso, se em algum momento decidir voltar, terá que pedir aprovação do Administrador.',
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: <Widget>[
            Center(
              child: Column(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Fecha o diálogo
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      userController.toggleUserStatus(userController.user!.id);
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Conta Desativada'),
                            content: const Text(
                                'A conta foi desativada, caso queira ativar novamente a conta entre em contato com um administrador.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pop(); // Fecha o diálogo
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SobreAppPage(),
                                    ),
                                  );
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: const Text(
                      'Confirmar Inativação',
                      style: TextStyle(color: Colors.black45),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    isAdminMode = widget.isAdminMode; // Inicializa o estado do modo admin
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    //final double screenWidth = MediaQuery.of(context).size.width;

    // Verificar se a tela é menor que 369x662
    final bool isSmallScreen = screenHeight < 668;

    // Define a cor do semicírculo com base no modo administrador
    Color semicircleColor =
        isAdminMode ? Colors.black : const Color(0xFFFF7801);

    // Definir escalas para as fontes e widgets de acordo com o tamanho da tela
    double textScaleFactor = isSmallScreen ? 0.8 : 1.2; // Escala de texto
    // Escala de botões e ícones
    double semicircleHeight = isSmallScreen
        ? screenHeight * 0.15
        : screenHeight * 0.15; // Ajuste do semicírculo

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          _buildHeader(semicircleHeight, semicircleColor, textScaleFactor),
          SizedBox(height: 20.h),
          // Retângulo cinza com o conteúdo e os botões
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.7, // Altura ajustada
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const TermosDeUsoWidget(), // Widget dos Termos de Uso

                  SizedBox(height: 16.h),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => _showInativaConfirmationDialog(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0)),
                        side: const BorderSide(color: Colors.white, width: 1),
                        // Força 200 de largura
                        fixedSize: Size(180.w, 48.h),
                      ),
                      child: const Text(
                        'Inativar Conta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),
                  Center(
                    child: TextButton(
                      onPressed: () => _showDeleteConfirmationDialog(),
                      child: const Text(
                        'Excluir Conta',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.red), // Define a cor do texto
                      ),
                    ),
                  ),
                  //SizedBox(height: 10.h),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Voltar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isAdminMode
          ? const CustomBottomNavigationBarAdm(currentIndex: 3)
          : const CustomBottomNavigationBar(currentIndex: 3),
    );
  }

  Widget _buildHeader(
      double semicircleHeight, Color semicircleColor, double textScaleFactor) {
    return Container(
      width: double.infinity,
      height: semicircleHeight,
      decoration: BoxDecoration(
        color: semicircleColor,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(MediaQuery.of(context).size.width),
        ),
      ),
      child: const Stack(
        children: [
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Privacidade e Uso da Conta',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
