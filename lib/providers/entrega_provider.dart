import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:latlong2/latlong.dart';
import '../models/entrega.dart';
import '../services/servico_ia_logistica.dart';
import '../services/servico_notificacao.dart';

class EntregaProvider extends ChangeNotifier {
  final box = Hive.box('entregas');

  String _gerarId() =>
      '${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(9999)}';

  Entrega? entregaAtual;
  List<Entrega> historico = [];

  Timer? _timerTracking;
  double _progresso = 0.0; // 0.0 a 1.0 do trajeto total

  EntregaProvider() {
    carregarHistorico();
  }

  void carregarHistorico() {
    historico = box.values
        .map((item) => Entrega.fromMap(item as Map))
        .toList()
        .reversed
        .toList();
    notifyListeners();
  }

  Future<void> solicitarEntrega({
    required TipoEntrega tipo,
    required String descricao,
    required double latUsuario,
    required double lngUsuario,
  }) async {
    final random = Random();
    final anguloRad = random.nextDouble() * 2 * pi;
    final distanciaOrigemKm = 1.5 + random.nextDouble() * 4.5;

    // Converte a distância simulada em deslocamento aproximado de latitude/longitude.
    final deltaLat = (distanciaOrigemKm / 111.0) * cos(anguloRad);
    final deltaLng = (distanciaOrigemKm / 111.0) * sin(anguloRad);

    final origem = LatLng(latUsuario + deltaLat, lngUsuario + deltaLng);
    final destino = LatLng(latUsuario, lngUsuario);

    final distanciaKm = ServicoIALogistica.calcularDistanciaKm(origem, destino);
    final predicao = ServicoIALogistica.prever(
      distanciaKm: distanciaKm,
      velocidadeMediaKmh: tipo.velocidadeMediaKmh,
      horario: DateTime.now(),
    );

    final entrega = Entrega(
      id: _gerarId(),
      tipo: tipo,
      descricao: descricao,
      status: StatusEntrega.confirmado,
      latOrigem: origem.latitude,
      lngOrigem: origem.longitude,
      latDestino: destino.latitude,
      lngDestino: destino.longitude,
      latAtual: origem.latitude,
      lngAtual: origem.longitude,
      horarioSolicitacao: DateTime.now(),
      etaMinutos: predicao.etaMinutos,
      etaMinutosOriginal: predicao.etaMinutos,
      distanciaKm: distanciaKm,
      confiancaModelo: predicao.confianca,
    );

    entregaAtual = entrega;
    _progresso = 0.0;
    notifyListeners();

    await ServicoNotificacao.mostrar(
      '${tipo.emoji} ${tipo.titulo} confirmado',
      'Previsão de chegada: ${entrega.etaMinutos} min (confiança do modelo: ${entrega.confiancaModelo}%).',
    );

    _iniciarTracking();
  }

  void _iniciarTracking() {
    _timerTracking?.cancel();

    // Cada minuto previsto vira aproximadamente 1,4 segundo na demonstração.
    final totalTicks = max(6, (entregaAtual!.etaMinutosOriginal * 1.4).round());
    var ticksPassados = 0;
    var avisouACaminho = false;
    var avisouProximo = false;

    _timerTracking = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (entregaAtual == null) {
        timer.cancel();
        return;
      }

      ticksPassados++;
      _progresso = ticksPassados / totalTicks;

      final origem = LatLng(entregaAtual!.latOrigem, entregaAtual!.lngOrigem);
      final destino = LatLng(
        entregaAtual!.latDestino,
        entregaAtual!.lngDestino,
      );
      final novaPosicao = ServicoIALogistica.interpolarPosicao(
        origem,
        destino,
        _progresso,
      );

      entregaAtual!.latAtual = novaPosicao.latitude;
      entregaAtual!.lngAtual = novaPosicao.longitude;
      entregaAtual!.distanciaKm = ServicoIALogistica.calcularDistanciaKm(
        novaPosicao,
        destino,
      );
      entregaAtual!.etaMinutos = max(
        1,
        (entregaAtual!.etaMinutosOriginal * (1 - _progresso)).round(),
      );

      if (ticksPassados == (totalTicks * 0.4).round() &&
          entregaAtual!.status != StatusEntrega.concluido) {
        final imprevisto = ServicoIALogistica.sortearImprevisto();
        if (imprevisto != null) {
          entregaAtual!.houveImprevisto = true;
          entregaAtual!.mensagemImprevisto = imprevisto;
          entregaAtual!.etaMinutos += 2 + Random().nextInt(3);
          await ServicoNotificacao.mostrar(
            '⚠️ Atualização da rota',
            '$imprevisto. Novo ETA: ${entregaAtual!.etaMinutos} min.',
          );
        }
      }

      if (!avisouACaminho && _progresso > 0.15) {
        avisouACaminho = true;
        entregaAtual!.status = StatusEntrega.aCaminho;
        await ServicoNotificacao.mostrar(
          '${entregaAtual!.tipo.emoji} ${entregaAtual!.tipo.nomeAgente} a caminho',
          'Chegada estimada em ${entregaAtual!.etaMinutos} min.',
        );
      }

      if (!avisouProximo && _progresso > 0.75) {
        avisouProximo = true;
        entregaAtual!.status = StatusEntrega.proximo;
        await ServicoNotificacao.mostrar(
          '📍 Quase chegando!',
          '${entregaAtual!.tipo.nomeAgente} chega em ${entregaAtual!.etaMinutos} min.',
        );
      }

      if (_progresso >= 1.0) {
        entregaAtual!.status = StatusEntrega.concluido;
        entregaAtual!.etaMinutos = 0;
        entregaAtual!.horarioConcluido = DateTime.now();
        timer.cancel();

        await ServicoNotificacao.mostrar(
          '✅ ${entregaAtual!.tipo.titulo} concluído',
          'Confirme se está tudo certo no app.',
        );

        await box.add(entregaAtual!.toMap());
        carregarHistorico();
      }

      notifyListeners();
    });
  }

  void cancelarEntrega() {
    _timerTracking?.cancel();
    if (entregaAtual != null) {
      entregaAtual!.status = StatusEntrega.cancelado;
      box.add(entregaAtual!.toMap());
      carregarHistorico();
    }
    entregaAtual = null;
    _progresso = 0.0;
    notifyListeners();
  }

  void limparEntregaConcluida() {
    entregaAtual = null;
    _progresso = 0.0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timerTracking?.cancel();
    super.dispose();
  }
}
