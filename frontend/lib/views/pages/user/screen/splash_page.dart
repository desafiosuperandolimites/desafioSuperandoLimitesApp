part of '../../../env.dart';

class SplashPage extends StatefulWidget {
  final String? initialLink; // <--- Add this to receive the link

  const SplashPage({super.key, this.initialLink});

  @override
  SplashPageState createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Check login status *and* check if there's an incoming deep link
    _checkLoginStatus();
  }

  // 1) Check if user is logged in, but also handle the initialLink if it exists
  void _checkLoginStatus() async {
    try {
      // Tentando ler o token armazenado
      final String? token = await _storage.read(key: 'auth_token');

      // Simula um delay para a tela de splash
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      // If user opened the app via a deep link (e.g. superandolimites://noticia/SHARE_TOKEN)

      if (widget.initialLink != null && widget.initialLink!.isNotEmpty) {
        final uri = Uri.parse(widget.initialLink!);
        if (uri.scheme == 'superandolimites' && uri.host == 'noticia') {
          final segments = uri.pathSegments;
          if (segments.isNotEmpty) {
            final shareToken = segments[0];
            // Attempt to fetch the notícia
            final feedController = FeedNoticiaController();
            final noticia =
                await feedController.fetchNoticiaByShareToken(shareToken);

            if (noticia != null) {
              if (token == null || token.isEmpty) {
                return;
              } else {
                if (!mounted) return;
                return;
              }
            }
          }
        }
      }

      // 2. Carrega o usuário logado (para acessar idTipoPerfil)
      final userController =
          Provider.of<UserController>(context, listen: false);
      await userController.fetchCurrentUser();
      final user = userController.user;

      // 3. Decide a tela de destino
      //if (user == null) {
      // algo deu errado, não tem user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Erro ao recuperar usuário logado')),
      //);
      //return;
      // }

      final tipoPerfil =
          user?.idTipoPerfil; // Ex.: 1,2 -> admin, 3 -> user final

      // Verifica se o token é válido
      if (token != null && token.isNotEmpty) {
        if (tipoPerfil == 1 || tipoPerfil == 2) {
          // Admin
          // Se quiser rota dedicada: Navigator.pushReplacementNamed(context, '/perfilAdmin');
          // OU se vai usar uma classe de tela distinta, chame via MaterialPageRoute:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const PerfilPageAdmin()),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/perfil');
        }
      } else {
        Navigator.pushReplacementNamed(context, '/sobre');
      }
    } catch (e) {
      print('Erro ao acessar o token: $e');

      // Se houver erro na descriptografia, apagar os dados corrompidos
      await _storage.deleteAll();
      Navigator.pushReplacementNamed(context, '/sobre');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/image/Prancheta 2.png',
                    width: 200, height: 200),
                const SizedBox(height: 20),
                RotationTransition(
                  turns: _controller,
                  child: Image.asset('assets/image/bike_wheel.png',
                      width: 50, height: 50),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Copyright 2025 © Todos os direitos reservados - InovaFapto.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
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
