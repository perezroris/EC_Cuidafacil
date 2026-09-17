import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/contatos_provider.dart';

// usa openstreetmap porque nao precisa de chave de api
class TelaMapa extends StatefulWidget {
  const TelaMapa({super.key});

  @override
  State<TelaMapa> createState() => _TelaMapaState();
}

class _TelaMapaState extends State<TelaMapa> {
  LatLng? posicaoAtual;
  bool carregando = true;
  String? erro;

  @override
  void initState() {
    super.initState();
    buscarLocalizacao();
  }

  Future<void> buscarLocalizacao() async {
    try {
      final posicao = await Geolocator.getLastKnownPosition().timeout(
        const Duration(seconds: 2),
      );
      if (!mounted) return;
      setState(() {
        // Centro de São Paulo é o fallback estável da demonstração.
        posicaoAtual = posicao == null
            ? const LatLng(-23.5505, -46.6333)
            : LatLng(posicao.latitude, posicao.longitude);
        carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        posicaoAtual = const LatLng(-23.5505, -46.6333);
        carregando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contatos = context.watch<ContatosProvider>().listaContatos;
    final familiares = List<_Familiar>.generate(
      contatos.length,
      (index) => _Familiar.doContato(contatos[index].nome, index),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Minha Família'), centerTitle: true),
      body: carregando
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Buscando sua localização...',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : erro != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 70,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      erro!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          carregando = true;
                          erro = null;
                        });
                        buscarLocalizacao();
                      },
                      child: const Text('Tentar de novo'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: posicaoAtual!,
                      initialZoom: 15,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.cuidafacil.cuida_facil',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: posicaoAtual!,
                            width: 60,
                            height: 60,
                            child: const Icon(
                              Icons.person_pin_circle,
                              size: 60,
                              color: Colors.red,
                            ),
                          ),
                          // Posições simuladas até existir compartilhamento em tempo real.
                          ...familiares.map(
                            (f) => Marker(
                              point: LatLng(
                                posicaoAtual!.latitude + f.deslocLat,
                                posicaoAtual!.longitude + f.deslocLng,
                              ),
                              width: 50,
                              height: 50,
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 36,
                                    color: Colors.blue,
                                  ),
                                  Text(
                                    f.nome,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sua família',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (familiares.isEmpty)
                        const Text(
                          'Cadastre contatos para vê-los aqui.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        )
                      else
                        ...familiares.map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.blue,
                                  size: 22,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${f.nome} está a ${f.distancia} de você',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _Familiar {
  final String nome;
  final double deslocLat;
  final double deslocLng;
  final String distancia;

  const _Familiar(this.nome, this.deslocLat, this.deslocLng, this.distancia);

  factory _Familiar.doContato(String nome, int index) {
    const deslocamentos = [
      (0.008, 0.005, '1,2 km'),
      (-0.015, 0.012, '2,5 km'),
      (0.011, -0.009, '1,8 km'),
      (-0.007, -0.013, '2,1 km'),
      (0.016, -0.004, '2,9 km'),
    ];
    final dados = deslocamentos[index % deslocamentos.length];
    return _Familiar(nome, dados.$1, dados.$2, dados.$3);
  }
}
