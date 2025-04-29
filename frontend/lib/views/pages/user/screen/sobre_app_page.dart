part of '../../../env.dart';

class SobreAppPage extends StatelessWidget {
  const SobreAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    // Usando LayoutBuilder para ajustar os tamanhos dos elementos dinamicamente
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Scaffold(
          body: Stack(
            children: <Widget>[
              // Imagem de fundo preenchendo toda a tela
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/Tela1.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              // Sobreposição escura
              Container(
                color: Colors.black.withOpacity(0.1),
              ),
              // Máscara laranja com baixa opacidade
              Container(
                color:
                    const Color(0xFFFF7801).withOpacity(0.5), // Máscara laranja
              ),
              // circulo branco
              Container(
                width: double.infinity,
                height: screenHeight *
                    0.25, // Ajusta o tamanho relativo da meia bola conforme a altura da tela
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF), // Cor branca
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(screenHeight *
                        0.25), // Ajusta o tamanho relativo da curva
                  ),
                ),
              ),
              Positioned(
                top: screenHeight *
                    0.025, // Ajusta a posição conforme a altura da tela
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset('assets/image/Prancheta 2.png',
                      height: screenHeight * 0.18),
                ),
              ),
              // Conteúdo Principal
              Padding(
                padding: EdgeInsets.all(screenWidth *
                    0.08), // Ajusta o padding conforme a largura da tela
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                          height: screenHeight *
                              0.28), // Ajusta o espaçamento conforme a altura da tela
                      // Título "QUEM SOMOS"
                      Text(
                        'QUEM SOMOS',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize:
                                      20, // Ajusta o tamanho da fonte conforme a altura da tela
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      // Texto sobre a missão
                      Text(
                        'Temos o objetivo de estimular as pessoas a ultrapassarem suas barreiras pessoais, utilizando o esporte.',
                        textAlign: TextAlign.justify,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize:
                                  16, // Ajusta o tamanho da fonte conforme a altura da tela
                              color: Colors.white,
                            ),
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      // Título "MISSÃO:"
                      Text(
                        'MISSÃO:',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize:
                                      20, // Ajusta o tamanho da fonte conforme a altura da tela
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      // Lista de missões
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/image/verificado.png',
                                width: screenWidth * 0.05,
                                height: screenHeight * 0.02,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Text(
                                  'Inspirar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize:
                                            18, // Ajusta o tamanho da fonte conforme a altura da tela
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              Image.asset(
                                'assets/image/verificado.png',
                                width: screenWidth * 0.05,
                                height: screenHeight * 0.02,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Text(
                                  'Motivar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize:
                                            18, // Ajusta o tamanho da fonte conforme a altura da tela
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Row(
                            children: [
                              Image.asset(
                                'assets/image/verificado.png',
                                width: screenWidth * 0.05,
                                height: screenHeight * 0.02,
                              ),
                              SizedBox(width: screenWidth * 0.02),
                              Expanded(
                                child: Text(
                                  'Transformar Vidas',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontSize:
                                            18, // Ajusta o tamanho da fonte conforme a altura da tela
                                        color: Colors.white,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: screenHeight * 0.07),
                      // Botões de ação
                      Center(
                        child: Column(
                          children: [
                            // Botão para criar uma conta
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth:
                                    15, // Ajusta a largura conforme o padding
                              ),
                            ),
                            const SizedBox(height: 15),
                            // Botão para login
                            ConstrainedBox(
                              constraints: const BoxConstraints(
                                minWidth:
                                    15, // Ajusta a largura conforme o padding
                              ),
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/tipo-login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: screenWidth * 0.08,
                                      vertical: screenHeight * 0.015),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.01),
                                  ),
                                  side: const BorderSide(
                                      color: Colors.white, width: 1),
                                ),
                                child: const Text(
                                  'ENTRAR',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        16, // Ajusta o tamanho da fonte conforme a altura da tela
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Texto de copyright no rodapé
              Positioned(
                bottom: screenHeight * 0.01,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Copyright 2025 © Todos os direitos reservados - InovaFapto.',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.height *
                          0.015, // Usa o MediaQuery para ajustar o tamanho da fonte
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
