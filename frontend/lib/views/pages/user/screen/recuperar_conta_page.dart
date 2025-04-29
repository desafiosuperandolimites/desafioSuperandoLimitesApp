part of '../../../env.dart';

class RecuperarContaPage extends StatefulWidget {
  const RecuperarContaPage({super.key});

  @override
  RecuperarContaPageState createState() => RecuperarContaPageState();
}

class RecuperarContaPageState extends State<RecuperarContaPage> {
  final TextEditingController _emailController = TextEditingController();
  final RecuperarSenhaController _controller = RecuperarSenhaController();
  bool _isLoading = false; // Added for loading state

  Future<void> _requestPasswordReset() async {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    try {
      await _controller.requestPasswordReset(context, _emailController.text);
    } finally {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Fundo laranja preenchendo toda a tela
          Positioned.fill(
            child: Container(
              color: const Color(0xFFFF7801),
            ),
          ),
          // Meia bola branca no topo
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.width / 1.3,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(MediaQuery.of(context).size.width),
                ),
              ),
            ),
          ),
          // Logo fixada no topo dentro da bola branca
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset('assets/image/Prancheta 2.png', height: 200.h),
            ),
          ),
          // Formulário de recuperação de senha
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 330.h),
                  const Text(
                    'Digite o e-mail cadastrado:',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 20.h),
                  TextField(
                    controller: _emailController, // Bind the controller
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5), width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5), width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.5),
                            width:
                                1), // Altere para a cor desejada ou deixe como cinza
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _requestPasswordReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Fundo cinza claro
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      side: const BorderSide(color: Colors.white, width: 1),
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                              SizedBox(width: 16.w),
                              Text(
                                'Enviando seu email...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20.sp,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            'Enviar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                  ),
                  SizedBox(height: 10.h),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/tipo-login');
                    },
                    child: Text(
                      'Voltar',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
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
