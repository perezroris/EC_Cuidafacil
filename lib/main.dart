import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/contatos_provider.dart';
import 'providers/remedios_provider.dart';
import 'providers/entrega_provider.dart';
import 'services/servico_notificacao.dart';
import 'screens/tela_splash.dart';
import 'screens/tela_cadastro.dart';
import 'screens/tela_inicial.dart';
import 'screens/tela_remedios.dart';
import 'screens/tela_novo_remedio.dart';
import 'screens/tela_contatos.dart';
import 'screens/tela_perfil.dart';
import 'screens/tela_mapa.dart';
import 'screens/tela_entrega.dart';
import 'screens/tela_nova_entrega.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  await Hive.openBox('remedios');
  await Hive.openBox('contatos');
  await Hive.openBox('usuario');
  await Hive.openBox('entregas');

  await ServicoNotificacao.init();

  runApp(const AppCuidaFacil());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const TelaSplash()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const TelaCadastro(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const TelaInicial()),
    GoRoute(
      path: '/remedios',
      builder: (context, state) => const TelaRemedios(),
    ),
    GoRoute(
      path: '/remedios/novo',
      builder: (context, state) => const TelaNovoRemedio(),
    ),
    GoRoute(
      path: '/contatos',
      builder: (context, state) => const TelaContatos(),
    ),
    GoRoute(path: '/perfil', builder: (context, state) => const TelaPerfil()),
    GoRoute(path: '/mapa', builder: (context, state) => const TelaMapa()),
    GoRoute(path: '/entrega', builder: (context, state) => const TelaEntrega()),
    GoRoute(
      path: '/entrega/nova',
      builder: (context, state) => const TelaNovaEntrega(),
    ),
  ],
);

class AppCuidaFacil extends StatelessWidget {
  const AppCuidaFacil({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RemediosProvider()),
        ChangeNotifierProvider(create: (_) => ContatosProvider()),
        ChangeNotifierProvider(create: (_) => EntregaProvider()),
      ],
      child: MaterialApp.router(
        title: 'CuidaFácil',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontSize: 20),
            bodyMedium: TextStyle(fontSize: 18),
            titleLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 60),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
