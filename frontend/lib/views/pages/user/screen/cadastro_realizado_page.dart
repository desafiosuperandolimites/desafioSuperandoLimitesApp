part of '../../../env.dart';

class CadastroRealizadoPage extends StatelessWidget {
  const CadastroRealizadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    //final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Imagem de fundo preenchendo toda a tela
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/Tela5.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          // Sobreposição escura
          Container(
            color: Colors.black.withOpacity(0.1),
          ),
          // Logo fixada no topo
          Positioned(
            top: screenHeight * 0.055,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('assets/image/Prancheta 2.png',
                  height: screenHeight * 0.1),
            ),
          ),
          // Conteúdo Principal
          Padding(
            padding: EdgeInsets.all(32.w),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Centraliza o conteúdo no eixo horizontal
                children: <Widget>[
                  SizedBox(
                      height: 400.h), // Ajuste a altura conforme necessário
                  // Texto sobre o sucesso do cadastro
                  Center(
                    child: Text(
                      'Cadastro Realizado \n com sucesso.',
                      textAlign: TextAlign.center, // Centraliza o texto
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // Ícone "ok" centralizado
                  Center(
                    child: Image.asset('assets/image/verificado.png',
                        height: 75.h),
                  ),
                  SizedBox(height: 32.h),
                  // Botão para login
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 250
                          .w, // Define um limite máximo de largura para o botão
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TipoLoginPage(
                                  noticiaExiste:
                                      false)), // Navega para LoginEmailPage
                        );
                      },
                      icon: const Icon(Icons.login, size: 20),
                      label: const Text('FAZER LOGIN',
                          style: TextStyle(fontSize: 20)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white, // Cor de fundo
                        foregroundColor: Colors.green, // Cor do texto
                        padding: EdgeInsets.symmetric(
                            horizontal: 32.w, vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(4.r), // Menos arredondado
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
    );
  }
}
