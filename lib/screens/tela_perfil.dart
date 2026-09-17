import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TelaPerfil extends StatelessWidget {
  const TelaPerfil({super.key});

  @override
  Widget build(BuildContext context) {
    final boxUsuario = Hive.box('usuario');
    final nome = boxUsuario.get('nome', defaultValue: '');
    final cidade = boxUsuario.get('cidade', defaultValue: '');
    final estado = boxUsuario.get('estado', defaultValue: '');

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              child: FaIcon(FontAwesomeIcons.user, size: 44),
            ),
            const SizedBox(height: 16),
            Text(
              nome,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              '$cidade - $estado',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.contacts,
                  color: Colors.teal,
                  size: 32,
                ),
                title: const Text(
                  'Meus contatos',
                  style: TextStyle(fontSize: 18),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/contatos'),
              ),
            ),

            const SizedBox(height: 32),

            OutlinedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Apagar tudo?'),
                    content: const Text(
                      'Todos os seus dados serão apagados e você voltará ao cadastro inicial.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Hive.box('usuario').clear();
                          await Hive.box('remedios').clear();
                          await Hive.box('contatos').clear();
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ctx.go('/onboarding');
                          }
                        },
                        child: const Text(
                          'Apagar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              label: const Text(
                'Apagar meus dados',
                style: TextStyle(color: Colors.red),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
