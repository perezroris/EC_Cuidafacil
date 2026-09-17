import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../models/contato.dart';
import '../providers/contatos_provider.dart';
import '../services/servico_viacep.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final nomeController = TextEditingController();
  final cepController = TextEditingController();
  final cidadeController = TextEditingController();
  final estadoController = TextEditingController();
  final nomeContatoController = TextEditingController();
  final telefoneContatoController = TextEditingController();

  final servicoCep = ServicoViaCep();
  bool buscandoCep = false;

  final List<Contato> contatosTemp = [];

  Future<void> buscarCidadePeloCep() async {
    setState(() => buscandoCep = true);

    final resultado = await servicoCep.buscarCep(cepController.text);

    setState(() => buscandoCep = false);

    if (resultado != null) {
      cidadeController.text = resultado['cidade']!;
      estadoController.text = resultado['estado']!;
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CEP não encontrado, preencha a cidade manualmente'),
        ),
      );
    }
  }

  void adicionarContatoTemp() {
    final nome = nomeContatoController.text.trim();
    final telefone = telefoneContatoController.text.trim();

    if (nome.isEmpty || telefone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha nome e telefone do contato')),
      );
      return;
    }
    if (contatosTemp.length >= 5) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Máximo de 5 contatos')));
      return;
    }

    setState(() {
      contatosTemp.add(Contato(nome: nome, telefone: telefone));
      nomeContatoController.clear();
      telefoneContatoController.clear();
    });
  }

  Future<void> finalizarCadastro() async {
    if (nomeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Digite seu nome')));
      return;
    }
    if (contatosTemp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos 1 contato de emergência'),
        ),
      );
      return;
    }

    final provider = context.read<ContatosProvider>();

    final boxUsuario = Hive.box('usuario');
    await boxUsuario.put('nome', nomeController.text.trim());
    await boxUsuario.put('cidade', cidadeController.text.trim());
    await boxUsuario.put('estado', estadoController.text.trim());
    for (final contato in contatosTemp) {
      await provider.adicionarContato(contato);
    }

    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bem-vindo!')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vamos fazer seu cadastro',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'É rapidinho, só o essencial.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: nomeController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Seu nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: cepController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: 'CEP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: buscandoCep ? null : buscarCidadePeloCep,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(100, 56),
                    ),
                    child: buscandoCep
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Buscar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: cidadeController,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: estadoController,
                    style: const TextStyle(fontSize: 20),
                    decoration: const InputDecoration(
                      labelText: 'UF',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),

            const Text(
              'Contatos de emergência',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Quem deve ser avisado se você precisar de ajuda?',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: nomeContatoController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Nome do contato',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telefoneContatoController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: adicionarContatoTemp,
              icon: const Icon(Icons.person_add),
              label: const Text('Adicionar contato'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),

            const SizedBox(height: 12),

            ...contatosTemp.asMap().entries.map((entry) {
              final i = entry.key;
              final c = entry.value;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.person, size: 32),
                  title: Text(c.nome, style: const TextStyle(fontSize: 18)),
                  subtitle: Text(c.telefone),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() => contatosTemp.removeAt(i)),
                  ),
                ),
              );
            }),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: finalizarCadastro,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              child: const Text('Começar a usar'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
