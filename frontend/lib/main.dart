// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:provider/provider.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:superando_limites/controllers/env_controllers.dart';
// import 'package:superando_limites/routes/routes.dart';

// void main() async {
//   await dotenv.load(fileName: ".env");
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//   ]);
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(
//             create: (_) => UserController()..fetchCurrentUser()),
//         ChangeNotifierProvider(create: (_) => EnderecoController()),
//         ChangeNotifierProvider(
//             create: (_) => PagamentoInscricaoController()), // Adicione aqui
//         ChangeNotifierProvider(
//             create: (_) => DuvidaEventoController()), // Adicionado aqui
//         ChangeNotifierProvider(
//             create: (_) => RespostaDuvidaController()), // Adicione este
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(430, 932), // Base design size
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return MaterialApp(
//           title: 'Superando Limites',
//           theme: ThemeData(
//             inputDecorationTheme: InputDecorationTheme(
//               filled: true,
//               fillColor: Colors.white,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0.r),
//               ),
//               focusedBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: Colors.orange, width: 2.0),
//                 borderRadius: BorderRadius.circular(8.0.r),
//               ),
//             ),
//             textSelectionTheme: const TextSelectionThemeData(
//                 selectionColor: Colors.orange,
//                 cursorColor: Colors.orange,
//                 selectionHandleColor: Colors.orange),
//             primarySwatch: Colors.orange,
//           ),
//           localizationsDelegates: const [
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],
//           supportedLocales: const [
//             Locale('pt', 'BR'),
//           ],
//           initialRoute: '/splash', // Set the splash page as the initial route
//           routes:
//               getApplicationRoutes(), // Use the routes from the routes.dart file
//           builder: (context, widget) {
//             ScreenUtil.init(
//               context,
//               designSize: const Size(430, 932),
//               minTextAdapt: true,
//             );
//             return widget!;
//           },
//         );
//       },
//     );
//   }
// }

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:superando_limites/controllers/env_controllers.dart';
import 'package:superando_limites/firebase_options.dart';
import 'package:superando_limites/routes/routes.dart';
import 'package:superando_limites/services/env_services.dart';
import 'package:superando_limites/views/env.dart';
import 'package:app_links/app_links.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Configuração Firebase
  );

  await dotenv.load(fileName: ".env");
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Inicializar Firebase Messaging
  final firebaseMessagingService = FirebaseMessagingService();
  await firebaseMessagingService.initialize();

  String? initialLink; // <--- Adicione esta linha

  try{
    final applinks = AppLinks();

    initialLink = await applinks.getInitialLinkString();
  } on PlatformException {
    // Trate exceções
  } on FormatException {
    // Trate link mal-formatado
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => UserController()..fetchCurrentUser()),
        ChangeNotifierProvider(create: (_) => EnderecoController()),
        ChangeNotifierProvider(
            create: (_) => PagamentoInscricaoController()), // Adicione aqui
        ChangeNotifierProvider(
            create: (_) => DuvidaEventoController()), // Adicionado aqui
        ChangeNotifierProvider(
            create: (_) => RespostaDuvidaController()), // Adicione este
        ChangeNotifierProvider(
            create: (context) => NotificacaoController()
              ..initializeWithUser(
                  Provider.of<UserController>(context, listen: false))),
      ],
      child: MyApp(initialLink: initialLink), // Passar o link inicial
    ),
  );
}

class MyApp extends StatefulWidget {
  final String? initialLink; // <--- Adicione o link inicial
  MyApp({super.key, this.initialLink});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  late final AppLinks _appLinks;                // Instância do app_links
  StreamSubscription<Uri>? _linkSubscription;   // Para escutar links

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  // Configura o AppLinks
  Future<void> _initDeepLinks() async {
    // 1) Instanciar AppLinks
    _appLinks = AppLinks();

    // 3) Escutar links enquanto o app roda
    _linkSubscription = _appLinks.uriLinkStream.listen((Uri uri) {
      _handleIncomingLink(uri.toString());
    });
  }

   // Função que processa o link
  void _handleIncomingLink(String link) {
    final uri = Uri.parse(link);
    if (uri.scheme == 'superandolimites' && uri.host == 'noticia') {
      final segments = uri.pathSegments;
      if (segments.isNotEmpty) {
        final shareToken = segments[0];
        _abrirNoticiaPorToken(shareToken);
      }
    }
  }

  // Busca a notícia e navega
  Future<void> _abrirNoticiaPorToken(String shareToken) async {
    final feedController = FeedNoticiaController();
    final noticia = await feedController.fetchNoticiaByShareToken(shareToken);

    if (noticia != null) {
      final String? token = await AuthController().getToken();
      if (token == null || token.isEmpty) {
        // Vai para tela de login, depois tela de detalhe
        _navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => TipoLoginPage(
            noticiaExiste: true,
            noticia: noticia,
          )),
        );
      } else {
        // Logado => direto para DetalheNoticiaPage
        _navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => DetalheNoticiaPage(noticia: noticia),
          ),
        );
      }
    } else {
      debugPrint('Notícia não encontrada para token $shareToken');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932), // Base design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Superando Limites',
          navigatorKey: _navigatorKey,
          theme: ThemeData(
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.orange, width: 2.0),
                borderRadius: BorderRadius.circular(8.0.r),
              ),
            ),
            textSelectionTheme: const TextSelectionThemeData(
                selectionColor: Colors.orange,
                cursorColor: Colors.orange,
                selectionHandleColor: Colors.orange),
            primarySwatch: Colors.orange,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('pt', 'BR'),
          ],
          initialRoute: '/splash', // Set the splash page as the initial route
          routes:
              getApplicationRoutes(widget.initialLink), // Use the routes from the routes.dart file
          builder: (context, widget) {
            ScreenUtil.init(
              context,
              designSize: const Size(430, 932),
              minTextAdapt: true,
            );
            return widget!;
          },
        );
      },
    );
  }
}
