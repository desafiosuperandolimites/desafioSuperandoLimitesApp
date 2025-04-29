part of '../../../env.dart';

class RecuperarEnviadoPage extends StatelessWidget {
  const RecuperarEnviadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    //double iconScaleFactor =
    screenHeight < 668 ? 0.8 : 1.0; // Fator de escala dos ícones
    double buttonScaleFactor =
        screenHeight < 668 ? 0.8 : 1.0; // Fator de escala dos botões
    // Adicionando o delay de 3 segundos antes de redirecionar
    Future.delayed(const Duration(seconds: 2), () {
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const TipoLoginPage(noticiaExiste: false)),
      );
    });

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Imagem de fundo preenchendo toda a tela
          // Fundo laranja preenchendo toda a tela
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFF7801), // Cor laranja como fundo
            ),
          ),
          // Meia bola branca no topo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width /
                  1.3, // Ajusta o tamanho da bola
              decoration: BoxDecoration(
                color: Colors.white, // Cor branca para a bola
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(MediaQuery.of(context)
                      .size
                      .width), // Curva para formar a bola
                ),
              ),
            ),
          ),
          // Texto "Vá para o seu e-mail" centralizado no topo
          Positioned(
            top: 80.h,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('assets/image/Prancheta 2.png', height: 200.h),
            ),
          ),
          // Imagem de e-mail enviado
          Positioned(
            top: 360 * buttonScaleFactor,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('assets/image/enviado.png', height: 80.h),
            ),
          ),
          // Formulário de recuperação de senha
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                      height: 110 *
                          buttonScaleFactor), // Espaço para empurrar o formulário para baixo
                  // Texto de instrução
                  Center(
                    child: Text(
                      'E-mail de recuperação enviado, entre em seu e-mail e siga as instruções para recuperar sua senha.',
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Texto de copyright no rodapé
          Positioned(
            bottom: 16.h,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                'Copyright 2025 © Todos os direitos reservados - InovaFapto.',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
