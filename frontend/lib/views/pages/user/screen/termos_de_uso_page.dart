part of '../../../env.dart';

class TermosDeUsoPage extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const TermosDeUsoPage({super.key, required this.registrationData});

  @override
  TermosDeUsoPageState createState() => TermosDeUsoPageState();
}

class TermosDeUsoPageState extends State<TermosDeUsoPage> {
  bool _isChecked = false;
  final bool _isLoading = false; // Add loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          // Meia bola na parte superior
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width / 4,
            decoration: BoxDecoration(
              color: const Color(0xFFFF7801),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(MediaQuery.of(context).size.width),
              ),
            ),
            child: const Center(
              child: Text(
                "Termos de Uso do App",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Retângulo fixo
          Container(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.60,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child:
                const TermosDeUsoWidget(), // Certifique-se de que este widget está correto
          ),
          // Checkbox para "Li e aceito os termos"
          Padding(
            padding: const EdgeInsets.only(
                right: 20.0), // Ajusta o espaçamento à direita
            child: Transform.translate(
              offset:
                  const Offset(20, 0), // Move o botão um pouco para a direita
              child: SizedBox(
                width: 250, // Defina a largura desejada
                child: CheckboxListTile(
                  title: const Text(
                    "Li e aceito os termos",
                    style: TextStyle(color: Colors.black),
                  ),
                  value: _isChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isChecked = value!;
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.green,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),
          if (_isLoading) const CircularProgressIndicator(),
          // Botão "Aceitar"
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Centraliza os botões
            children: <Widget>[
              ElevatedButton(
                onPressed: _isChecked
                    ? () async {
                        bool success = false;
                        try {
                          // Call the registration function with the passed registration data
                          success = await CadastroController()
                              .register(context, widget.registrationData);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Erro ao cadastrar: $e')),
                          );
                        }

                        if (success) {
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(
                              context, '/cadastro-realizado');
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  side: const BorderSide(color: Colors.white, width: 1),
                ),
                child: const Text(
                  'Aceitar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),

              SizedBox(width: 20.w), // Espaçamento entre os botões
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CadastroPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(
                      255, 200, 200, 200), // Fundo cinza claro
                  padding:
                      EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  elevation:
                      0, // Remove a elevação (sombra) para parecer mais plano
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(
                    color:
                        Color.fromARGB(255, 90, 90, 90), // Texto cinza escuro
                    fontWeight: FontWeight.normal,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),

          // Logo Prancheta 1
          Center(
            child: Image.asset('assets/image/Prancheta 1.png', height: 100.h),
          ),
        ],
      ),
    );
  }
}
