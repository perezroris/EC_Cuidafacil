import 'dart:math';
import 'package:latlong2/latlong.dart';

// No MVP, a previsão é simulada localmente com distância, velocidade e trânsito.
class ResultadoPredicao {
  final int etaMinutos;
  final int confianca;
  final double fatorTransito;

  ResultadoPredicao({
    required this.etaMinutos,
    required this.confianca,
    required this.fatorTransito,
  });
}

class ServicoIALogistica {
  static final _random = Random();
  static final _distancia = const Distance();

  static double calcularDistanciaKm(LatLng origem, LatLng destino) {
    final metros = _distancia.as(LengthUnit.Meter, origem, destino);
    return metros / 1000;
  }

  static ResultadoPredicao prever({
    required double distanciaKm,
    required double velocidadeMediaKmh,
    required DateTime horario,
  }) {
    final fatorTransito = _fatorTransito(horario);
    final velocidadeEfetiva = velocidadeMediaKmh / fatorTransito;

    final horasViagem = distanciaKm / velocidadeEfetiva;
    var minutos = (horasViagem * 60).round();

    minutos += 3;

    final ruido = _random.nextInt(3) - 1; // -1, 0 ou +1
    minutos = max(2, minutos + ruido);

    final confianca = fatorTransito > 1.15
        ? 78 + _random.nextInt(10)
        : 88 + _random.nextInt(10);

    return ResultadoPredicao(
      etaMinutos: minutos,
      confianca: min(confianca, 97),
      fatorTransito: fatorTransito,
    );
  }

  static double _fatorTransito(DateTime horario) {
    final hora = horario.hour;
    final pico =
        (hora >= 7 && hora < 9) ||
        (hora >= 12 && hora < 14) ||
        (hora >= 18 && hora < 20);
    return pico ? 1.35 : 1.0;
  }

  static String? sortearImprevisto() {
    final chance = _random.nextInt(100);
    if (chance < 12) {
      const eventos = [
        'Trânsito intenso identificado na rota',
        'Parada adicional necessária no trajeto',
        'Rota alternativa calculada por bloqueio na via',
      ];
      return eventos[_random.nextInt(eventos.length)];
    }
    return null;
  }

  static LatLng interpolarPosicao(
    LatLng origem,
    LatLng destino,
    double progresso,
  ) {
    final p = progresso.clamp(0.0, 1.0);
    return LatLng(
      origem.latitude + (destino.latitude - origem.latitude) * p,
      origem.longitude + (destino.longitude - origem.longitude) * p,
    );
  }
}
