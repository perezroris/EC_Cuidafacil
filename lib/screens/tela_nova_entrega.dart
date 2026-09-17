import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/entrega.dart';
import '../providers/entrega_provider.dart';

class TelaNovaEntrega extends StatefulWidget {
  const TelaNovaEntrega({super.key});

  @override
  State<TelaNovaEntrega> createState() => _TelaNovaEntregaState();
}

class _TelaNovaEntregaState extends State<TelaNovaEntrega> {
  TipoEntrega? tipoEscolhido;
  final descricaoController = TextEditingController();
  bool solicitando = false;

  @override
  void dispose() {
    descricaoController.dispose();
    super.dispose();
  }

  Future<Position?> pegarLocalizacao() async {
    try {
      // Para a demonstração, uma posição já conhecida é suficiente. Evita
      // iniciar uma busca ativa de GPS, que pode travar em emuladores.
      return await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> confirmarSolicitacao() async {
    if (tipoEscolhido == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha o tipo de atendimento')),
      );
      return;
    }

    setState(() => solicitando = true);

    final posicao = await pegarLocalizacao();
    final lat = posicao?.latitude ?? -23.5505;
    final lng = posicao?.longitude ?? -46.6333;

    if (!mounted) return;

    await context.read<EntregaProvider>().solicitarEntrega(
      tipo: tipoEscolhido!,
      descricao: descricaoController.text.trim().isEmpty
          ? tipoEscolhido!.titulo
          : descricaoController.text.trim(),
      latUsuario: lat,
      lngUsuario: lng,
    );

    setState(() => solicitando = false);
    if (!mounted) return;
    context.go('/entrega');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Entrega/Atendimento'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O que você precisa hoje?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Nossa IA calcula o tempo estimado e acompanha tudo em tempo real.',
              style: TextStyle(fontSize: 15, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),

            ...TipoEntrega.values.map(
              (tipo) => _CardTipo(
                tipo: tipo,
                selecionado: tipoEscolhido == tipo,
                onTap: () => setState(() => tipoEscolhido = tipo),
              ),
            ),

            const SizedBox(height: 20),
            TextField(
              controller: descricaoController,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'Detalhes (opcional)',
                hintText: 'Ex: Losartana 50mg, 1 caixa',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: solicitando ? null : confirmarSolicitacao,
              icon: solicitando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.smart_toy),
              label: Text(
                solicitando ? 'Calculando previsão...' : 'Solicitar agora',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6D28D9),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardTipo extends StatelessWidget {
  final TipoEntrega tipo;
  final bool selecionado;
  final VoidCallback onTap;

  const _CardTipo({
    required this.tipo,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: selecionado ? const Color(0xFFEDE9FE) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selecionado ? const Color(0xFF6D28D9) : Colors.transparent,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(tipo.emoji, style: const TextStyle(fontSize: 30)),
        title: Text(
          tipo.titulo,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
        subtitle: Text('~${tipo.velocidadeMediaKmh.toInt()} km/h em média'),
        trailing: selecionado
            ? const Icon(Icons.check_circle, color: Color(0xFF6D28D9))
            : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
