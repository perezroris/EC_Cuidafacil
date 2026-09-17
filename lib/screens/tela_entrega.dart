import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../models/entrega.dart';
import '../providers/entrega_provider.dart';

class TelaEntrega extends StatelessWidget {
  const TelaEntrega({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EntregaProvider>();
    final entrega = provider.entregaAtual;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar ao menu principal',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Entregas & Atendimentos'),
        centerTitle: true,
      ),
      floatingActionButton: entrega == null
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/entrega/nova'),
              backgroundColor: const Color(0xFF6D28D9),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Solicitar',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: entrega == null
          ? _SemEntregaAtiva(historico: provider.historico)
          : _TrackingAtivo(entrega: entrega, provider: provider),
    );
  }
}

class _SemEntregaAtiva extends StatelessWidget {
  final List<Entrega> historico;
  const _SemEntregaAtiva({required this.historico});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const FaIcon(
                  FontAwesomeIcons.truckMedical,
                  size: 50,
                  color: Color(0xFF6D28D9),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nenhuma entrega em andamento',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'Toque em "Solicitar" para pedir um remédio, atendimento, exame ou fisioterapia em domicílio.',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (historico.isNotEmpty) ...[
            const SizedBox(height: 28),
            const Text(
              'Histórico',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...historico.map(
              (e) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Text(
                    e.tipo.emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                  title: Text(
                    e.tipo.titulo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${e.status.titulo} • ${e.distanciaKm.toStringAsFixed(1)} km • previsto ${e.etaMinutosOriginal} min',
                  ),
                  trailing: Icon(
                    e.status == StatusEntrega.concluido
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: e.status == StatusEntrega.concluido
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrackingAtivo extends StatelessWidget {
  final Entrega entrega;
  final EntregaProvider provider;
  const _TrackingAtivo({required this.entrega, required this.provider});

  Color _corStatus(StatusEntrega status) {
    switch (status) {
      case StatusEntrega.confirmado:
        return Colors.blue;
      case StatusEntrega.aCaminho:
        return Colors.orange;
      case StatusEntrega.proximo:
        return Colors.deepOrange;
      case StatusEntrega.concluido:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final origem = LatLng(entrega.latOrigem, entrega.lngOrigem);
    final destino = LatLng(entrega.latDestino, entrega.lngDestino);
    final atual = LatLng(entrega.latAtual, entrega.lngAtual);
    final concluido = entrega.status == StatusEntrega.concluido;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: FlutterMap(
            options: MapOptions(initialCenter: atual, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cuidafacil.cuida_facil',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [origem, destino],
                    strokeWidth: 3,
                    color: Colors.grey,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: destino,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.home,
                      size: 40,
                      color: Colors.green,
                    ),
                  ),
                  Marker(
                    point: atual,
                    width: 50,
                    height: 50,
                    child: Icon(
                      entrega.tipo == TipoEntrega.medicamento
                          ? Icons.delivery_dining
                          : Icons.local_hospital,
                      size: 40,
                      color: const Color(0xFF6D28D9),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          flex: 4,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entrega.tipo.emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entrega.tipo.titulo,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _corStatus(
                          entrega.status,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        entrega.status.titulo,
                        style: TextStyle(
                          color: _corStatus(entrega.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1B4B),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.smart_toy,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Previsão calculada por IA',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        concluido ? 'Concluído' : '${entrega.etaMinutos} min',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Confiança do modelo: ${entrega.confiancaModelo}%  •  ${entrega.distanciaKm.toStringAsFixed(1)} km restantes',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 14,
                        ),
                      ),
                      if (entrega.houveImprevisto) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.info,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                entrega.mensagemImprevisto ?? '',
                                style: const TextStyle(
                                  color: Colors.amber,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),
                Text(
                  entrega.descricao,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),

                const SizedBox(height: 24),
                if (concluido)
                  ElevatedButton.icon(
                    onPressed: () => provider.limparEntregaConcluida(),
                    icon: const Icon(Icons.check),
                    label: const Text('OK, entendido'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: () => provider.cancelarEntrega(),
                    icon: const Icon(Icons.close, color: Colors.red),
                    label: const Text(
                      'Cancelar solicitação',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
