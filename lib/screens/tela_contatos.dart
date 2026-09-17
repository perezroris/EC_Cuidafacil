import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/contato.dart';
import '../providers/contatos_provider.dart';

class TelaContatos extends StatelessWidget {
  const TelaContatos({super.key});

  void abrirDialogNovoContato(BuildContext context) {
    final nomeController = TextEditingController();
    final telefoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Novo contato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeController,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: telefoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nome = nomeController.text.trim();
              final telefone = telefoneController.text.trim();
              if (nome.isEmpty || telefone.isEmpty) return;

              context.read<ContatosProvider>().adicionarContato(
                Contato(nome: nome, telefone: telefone),
              );
              Navigator.pop(ctx);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ContatosProvider>();
    final contatos = provider.listaContatos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos de Emergência'),
        centerTitle: true,
      ),
      floatingActionButton: contatos.length < 5
          ? FloatingActionButton.extended(
              onPressed: () => abrirDialogNovoContato(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Adicionar', style: TextStyle(fontSize: 18)),
            )
          : null,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber),
            ),
            child: const Text(
              'ℹ️ Essas pessoas serão avisadas quando você apertar o botão SOS.',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: contatos.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum contato cadastrado',
                      style: TextStyle(fontSize: 20, color: Colors.grey[600]),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: contatos.length,
                    itemBuilder: (context, index) {
                      final contato = contatos[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: const CircleAvatar(
                            radius: 26,
                            child: FaIcon(FontAwesomeIcons.user),
                          ),
                          title: Text(
                            contato.nome,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            contato.telefone,
                            style: const TextStyle(fontSize: 17),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                              size: 28,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Remover contato?'),
                                  content: Text(
                                    '${contato.nome} não será mais avisado em emergências.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('Cancelar'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        provider.removerContato(index);
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
