import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../providers/contatos_provider.dart';
import '../services/servico_notificacao.dart';
import '../services/servico_clima.dart';

class TelaInicial extends StatefulWidget {
  const TelaInicial({super.key});

  @override
  State<TelaInicial> createState() => _TelaInicialState();
}

class _TelaInicialState extends State<TelaInicial> {
  final servicoClima = ServicoClima();

  Map<String, dynamic>? dadosClima;
  String nomeUsuario = '';
  bool enviandoSos = false;

  final int freqCardiaca = 72;
  final int saturacao = 98;

  @override
  void initState() {
    super.initState();
    carregarDados();
  }

  Future<void> carregarDados() async {
    final boxUsuario = Hive.box('usuario');
    nomeUsuario = boxUsuario.get('nome', defaultValue: '');
    final cidade = boxUsuario.get('cidade', defaultValue: 'Sao Paulo');

    setState(() {});

    final clima = await servicoClima.buscarClima(cidade);
    if (mounted) setState(() => dadosClima = clima);
  }

  Future<Position?> pegarLocalizacao() async {
    try {
      // Não inicia uma busca ativa de GPS: no emulador ela pode ficar presa e
      // impedir a interface de responder. O SOS já trata posição indisponível.
      return await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 2),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> dispararSos() async {
    setState(() => enviandoSos = true);

    final contatos = context.read<ContatosProvider>().listaContatos;
    final posicao = await pegarLocalizacao();

    await ServicoNotificacao.mostrar(
      '🆘 SOS Enviado!',
      'Seus ${contatos.length} contatos de emergência foram avisados com sua localização.',
    );

    setState(() => enviandoSos = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 5),
        content: Text(
          posicao != null
              ? 'SOS enviado! ${contatos.length} contatos avisados.'
              : 'SOS enviado sem localização (GPS indisponível).',
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }

  void confirmarSos() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pedir ajuda?', style: TextStyle(fontSize: 26)),
        content: const Text(
          'Seus contatos de emergência serão avisados com a sua localização.',
          style: TextStyle(fontSize: 20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(140, 56),
            ),
            onPressed: () {
              Navigator.pop(context);
              dispararSos();
            },
            child: const Text('SIM, PRECISO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Olá, $nomeUsuario 👋',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.push('/perfil'),
                    icon: const Icon(Icons.account_circle, size: 40),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: dadosClima == null
                      ? const Row(
                          children: [
                            Icon(Icons.cloud_off, size: 32, color: Colors.grey),
                            SizedBox(width: 12),
                            Text(
                              'Carregando clima...',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  servicoClima.emojiDoClima(
                                    dadosClima!['icone'],
                                  ),
                                  style: const TextStyle(fontSize: 40),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${dadosClima!['temp'].toInt()}°C',
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      dadosClima!['descricao'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              servicoClima.dicaDoClima(
                                dadosClima!['temp'].toDouble(),
                                dadosClima!['icone'],
                              ),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0369A1),
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: enviandoSos ? null : confirmarSos,

                      onLongPress: enviandoSos ? null : dispararSos,
                      child: Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.red[600],
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 30,
                              spreadRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: enviandoSos
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 5,
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.sos,
                                      size: 80,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'PRECISO DE AJUDA',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque para pedir ajuda\nSegure para enviar direto',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.heartPulse,
                            color: Colors.red,
                            size: 30,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$freqCardiaca bpm',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Batimentos',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 60, color: Colors.grey[300]),
                      Column(
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.lungs,
                            color: Colors.blue,
                            size: 30,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$saturacao%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'Oxigênio',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Material(
                color: const Color(0xFF6D28D9),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/entrega'),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const FaIcon(
                          FontAwesomeIcons.truckMedical,
                          color: Colors.white,
                          size: 34,
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Entregas & Atendimentos',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Remédio, atendimento, exame ou fisioterapia — com ETA por IA',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _BotaoMenu(
                      icone: FontAwesomeIcons.pills,
                      texto: 'Remédios',
                      cor: Colors.orange,
                      onTap: () => context.push('/remedios'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _BotaoMenu(
                      icone: FontAwesomeIcons.addressBook,
                      texto: 'Contatos',
                      cor: Colors.teal,
                      onTap: () => context.push('/contatos'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: _BotaoMenu(
                  icone: FontAwesomeIcons.mapLocationDot,
                  texto: 'Mapa',
                  cor: Colors.indigo,
                  onTap: () => context.push('/mapa'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotaoMenu extends StatelessWidget {
  final FaIconData icone;
  final String texto;
  final Color cor;
  final VoidCallback onTap;

  const _BotaoMenu({
    required this.icone,
    required this.texto,
    required this.cor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              FaIcon(icone, size: 34, color: cor),
              const SizedBox(height: 8),
              Text(
                texto,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
