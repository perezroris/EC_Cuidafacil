import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/remedio.dart';
import '../providers/remedios_provider.dart';

class TelaNovoRemedio extends StatefulWidget {
  const TelaNovoRemedio({super.key});

  @override
  State<TelaNovoRemedio> createState() => _TelaNovoRemedioState();
}

class _TelaNovoRemedioState extends State<TelaNovoRemedio> {
  final nomeController = TextEditingController();
  final doseController = TextEditingController();

  TimeOfDay? horarioEscolhido;

  Future<void> escolherHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 8, minute: 0),
    );
    if (horario != null) {
      setState(() => horarioEscolhido = horario);
    }
  }

  Future<void> salvar() async {
    final nome = nomeController.text.trim();
    final dose = doseController.text.trim();

    if (nome.isEmpty || dose.isEmpty || horarioEscolhido == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos e escolha o horário'),
        ),
      );
      return;
    }

    final horarioFormatado =
        '${horarioEscolhido!.hour.toString().padLeft(2, '0')}:${horarioEscolhido!.minute.toString().padLeft(2, '0')}';

    final remedio = Remedio(nome: nome, dose: dose, horario: horarioFormatado);
    await context.read<RemediosProvider>().adicionarRemedio(remedio);

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$nome adicionado!')));
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Remédio'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nomeController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Nome do remédio',
                hintText: 'Ex: Losartana',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: doseController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(
                labelText: 'Dose',
                hintText: 'Ex: 1 comprimido de 50mg',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: escolherHorario,
              icon: const Icon(Icons.access_time, size: 28),
              label: Text(
                horarioEscolhido == null
                    ? 'Escolher horário'
                    : 'Horário: ${horarioEscolhido!.format(context)}',
                style: const TextStyle(fontSize: 20),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: salvar,
              icon: const Icon(Icons.check),
              label: const Text('Salvar remédio'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
