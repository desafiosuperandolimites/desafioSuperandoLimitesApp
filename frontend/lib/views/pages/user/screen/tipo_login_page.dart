part of '../../../env.dart';

class TipoLoginPage extends StatefulWidget {
  final bool noticiaExiste;
  final FeedNoticia? noticia;
  const TipoLoginPage({super.key, required this.noticiaExiste, this.noticia});

  @override
  _TipoLoginPageState createState() => _TipoLoginPageState();
}

class _TipoLoginPageState extends State<TipoLoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = AuthController();
  final GoogleAuthController _googleAuthController = GoogleAuthController();

  bool _isObscure = true;

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Os campos Email e senha devem ser preenchidos')),
      );
      return;
    }

    try {
      // 1. Faz login
      await _authController.login(email, password, context);
      if (!mounted) return;

      // 2. Carrega o usuário logado (para acessar idTipoPerfil)
      final userController =
          Provider.of<UserController>(context, listen: false);
      await userController.fetchCurrentUser();
      final user = userController.user;

      // 3. Decide a tela de destino
      if (user == null) {
        // algo deu errado, não tem user
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao recuperar usuário logado')),
        );
        return;
      }

      final tipoPerfil =
          user.idTipoPerfil; // Ex.: 1,2 -> admin, 3 -> user final

      // 4. Navegar conforme tipoPerfil
      if (tipoPerfil == 1 || tipoPerfil == 2) {
        // Admin
        // Se quiser rota dedicada: Navigator.pushReplacementNamed(context, '/perfilAdmin');
        // OU se vai usar uma classe de tela distinta, chame via MaterialPageRoute:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const PerfilPageAdmin()),
        );
      } else {
        // Usuário final
        // Verifica se existe uma notícia a ser vista
        if (!widget.noticiaExiste || widget.noticia == null) {
          // vai direto ao perfil user
          Navigator.pushReplacementNamed(context, '/perfil');
        } else {
          // Navega para a tela de detalhe de notícia
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DetalheNoticiaPage(noticia: widget.noticia!),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          // Semicírculo superior
          Container(
            width: double.infinity,
            height: screenWidth / 1.3,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.4,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7801),
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(screenWidth),
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/image/Prancheta 3.png',
                height: screenHeight * 0.2,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: screenHeight * 0.35),
                  // Formulário de Login
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: screenWidth * 0.8,
                      maxWidth: screenWidth * 0.9,
                    ),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.01),
                      ),
                      child: Column(
                        children: <Widget>[
                          const SizedBox(height: 20),
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Digite seu e-mail',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.01),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          TextField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Senha',
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.01),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                            ),
                          ),
                          //const SizedBox(height: 0),

                          const SizedBox(height: 10),
                          // Botão ENTRE
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.015),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      screenHeight * 0.01),
                                ),
                                side: const BorderSide(
                                    color: Colors.white, width: 1),
                              ),
                              child: const Text(
                                'ENTRE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/recuperar');
                                },
                                child: Text(
                                  'Esqueceu a senha?',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 0),
                          // Botões de Google e Apple lado a lado
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      if (kDebugMode) {
                                        print('Google sign-in initiated');
                                      }

                                      // Step 1: Trigger Google Sign-In
                                      final GoogleSignInAccount? googleUser =
                                          await GoogleSignIn().signIn();
                                      if (googleUser == null) {
                                        if (kDebugMode) {
                                          print('Google sign-in canceled');
                                        }
                                        // The user canceled the sign-in
                                        return;
                                      }
                                      if (kDebugMode) {
                                        print(
                                            'Google sign-in successful: ${googleUser.email}');
                                      }

                                      // Step 2: Authenticate with Firebase
                                      final GoogleSignInAuthentication
                                          googleAuth =
                                          await googleUser.authentication;

                                      final AuthCredential credential =
                                          GoogleAuthProvider.credential(
                                        accessToken: googleAuth.accessToken,
                                        idToken: googleAuth.idToken,
                                      );

                                      final UserCredential userCredential =
                                          await FirebaseAuth.instance
                                              .signInWithCredential(credential);

                                      if (kDebugMode) {
                                        print(
                                            'Firebase authentication successful');
                                      }

                                      // Step 3: Retrieve Firebase ID Token
                                      final String? idToken =
                                          await userCredential.user
                                              ?.getIdToken();
                                      if (idToken == null) {
                                        throw 'Failed to retrieve Firebase ID Token';
                                      }

                                      if (kDebugMode) {
                                        print(
                                            'Firebase ID Token retrieved: $idToken');
                                      }

                                      // Step 4: Pass Firebase ID Token to your backend
                                      await _googleAuthController
                                          .loginWithGoogle(idToken, context);

                                      // Navigate to profile page after successful login
                                      if (!context.mounted) return;
                                      if (kDebugMode) {
                                        print('Navigating to /perfil');
                                      }
                                      if (!widget.noticiaExiste ||
                                          widget.noticia == null) {
                                        Navigator.pushReplacementNamed(
                                            context, '/perfil');
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => DetalheNoticiaPage(
                                                noticia: widget.noticia!),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      if (kDebugMode) {
                                        print(
                                            'Error during Google sign-in: $e');
                                      }
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Erro ao fazer login com o Google: $e')),
                                      );
                                    }
                                  },
                                  icon: Image.asset(
                                      'assets/image/google_icon.png',
                                      height: 15),
                                  label: const Text('Google'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          screenHeight * 0.005),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Implementar ação de login com Apple
                                  },
                                  icon: Image.asset(
                                      'assets/image/apple_icon.png',
                                      height: 15),
                                  label: const Text('Apple'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: EdgeInsets.symmetric(
                                        vertical: screenHeight * 0.015),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          screenHeight * 0.005),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Novo no Superando Limites? ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/cadastro');
                                },
                                child: const Text(
                                  'Cadastre-se',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFFF7801), // Laranja
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  if (!widget.noticiaExiste)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/sobre');
                      },
                      child: const Text(
                        'Voltar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color.fromARGB(255, 0, 0, 0),
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
