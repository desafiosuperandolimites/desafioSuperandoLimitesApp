// routes.dart
import 'package:flutter/material.dart';
import 'package:superando_limites/views/env.dart';

Map<String, WidgetBuilder> getApplicationRoutes(String? initialLink) {
  return <String, WidgetBuilder>{
    // Páginas de autenticação e recuperação de conta
    '/splash': (BuildContext context) => SplashPage(initialLink: initialLink),
    //'/login': (BuildContext context) => const LoginEmailPage(),
    '/tipo-login': (BuildContext context) => TipoLoginPage(
          noticiaExiste: initialLink != null,
        ),
    '/cadastro': (BuildContext context) => const CadastroPage(),
    '/cadastro-realizado': (BuildContext context) =>
        const CadastroRealizadoPage(),
    '/recuperar': (BuildContext context) => const RecuperarContaPage(),
    '/recuperar-enviado': (BuildContext context) =>
        const RecuperarEnviadoPage(),

    // Páginas de perfil e termos
    '/perfil': (BuildContext context) => const PerfilPage(),
    '/sobre': (BuildContext context) => const SobreAppPage(),

    // Páginas principais (Home)
    '/home': (BuildContext context) => const HomePage(),
    '/home-adm': (BuildContext context) => const HomePageAdm(),

    // Gestão de usuários
    '/gestao-usuarios': (BuildContext context) => const GestaoUsuarioPage(),
    '/criar-usuario': (BuildContext context) => const CriarUsuarioPage(),

    // Gestão de eventos
    '/gestao-evento': (BuildContext context) => const GestaoEventosPage(),
    '/cadastrar-evento': (BuildContext context) => const CadastrarEventoPage(),
    '/inscricao_evento': (BuildContext context) => const InscricaoPage(),

    // Gestão de grupos
    '/gestao-grupo': (BuildContext context) => const GestaoGrupoPage(),
    '/cadastrar-grupo': (BuildContext context) => const CadastrarGrupoPage(),

    // Gestão de premiações
    '/gestao-premiacao': (BuildContext context) => const GestaoPremiacaoPage(),
    '/cadastrar-premiacao': (BuildContext context) =>
        const CadastrarPremiacaoPage(),

    // Cadastro de dados bancários
    '/cadastrar_dados_bancarios': (BuildContext context) =>
        const CadastrarDadosBancariosPage(),

    '/gestao_pagamentos': (BuildContext context) => const GestaoPagamentoPage(),
    '/gestao_noticias': (BuildContext context) => const GestaoNoticiaPage(),
    '/admin-depoimentos': (BuildContext context) =>
        const CadastrarDepoimentoPage(),
  };
}
