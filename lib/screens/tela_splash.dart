import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TelaSplash extends StatefulWidget {
  const TelaSplash({super.key});

  @override
  State<TelaSplash> createState() => _TelaSplashState();
}

class _TelaSplashState extends State<TelaSplash> {
  @override
  void initState() {
    super.initState();
    verificarCadastro();
  }

  Future<void> verificarCadastro() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final boxUsuario = Hive.box('usuario');
    final jaFezCadastro = boxUsuario.get('nome') != null;

    if (jaFezCadastro) {
      context.go('/home');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FaIcon(
              FontAwesomeIcons.handHoldingHeart,
              size: 90,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'CuidaFácil',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuidando de quem você ama',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
