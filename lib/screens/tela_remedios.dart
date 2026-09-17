import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/remedios_provider.dart';

class TelaRemedios extends StatelessWidget {
  const TelaRemedios({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RemediosProvider>();
    final remedios = provider.listaRemedios;

    return Scaffold(
      appBar: AppBar(title: const Text('Meus Remédios'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/remedios/novo'),
        icon: const Icon(Icons.add),
        label: const Text('Novo remédio', style: TextStyle(fontSize: 18)),
      ),
      body: remedios.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(
                    FontAwesomeIcons.pills,
                    size: 70,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum remédio cadastrado',
                    style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Toque no botão abaixo para adicionar',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: remedios.length,
              itemBuilder: (context, index) {
                final remedio = remedios[index];
                final tomado = remedio.tomadoHoje;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: tomado ? Colors.green[50] : null,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 26,
                      backgroundColor: tomado ? Colors.green : Colors.orange,
                      child: Text(
                        remedio.horario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      remedio.nome,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: tomado ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    subtitle: Text(
                      remedio.dose,
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          iconSize: 34,
                          icon: Icon(
                            tomado
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: tomado ? Colors.green : Colors.grey,
                          ),
                          onPressed: () {
                            provider.confirmarTomou(index);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  tomado
                                      ? '${remedio.nome} desmarcado'
                                      : '${remedio.nome} confirmado! 👍',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Remover remédio?'),
                                content: Text(
                                  '${remedio.nome} será removido da lista.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      provider.removerRemedio(index);
                                      Navigator.pop(ctx);
                                    },
                                    child: const Text(
                                      'Remover',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
