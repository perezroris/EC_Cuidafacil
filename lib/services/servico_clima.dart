import 'package:dio/dio.dart';

class ServicoClima {
  final dio = Dio();

  static const apiKey = String.fromEnvironment('OPENWEATHER_API_KEY');

  Future<Map<String, dynamic>?> buscarClima(String cidade) async {
    if (apiKey.isEmpty) return null;

    try {
      final response = await dio.get(
        'https://api.openweathermap.org/data/2.5/weather',
        queryParameters: {
          'q': cidade,
          'appid': apiKey,
          'units': 'metric',
          'lang': 'pt_br',
        },
      );

      final temp = response.data['main']['temp'];
      final descricao = response.data['weather'][0]['description'];
      final icone = response.data['weather'][0]['icon'];

      return {'temp': temp, 'descricao': descricao, 'icone': icone};
    } catch (_) {
      return null;
    }
  }

  String emojiDoClima(String icone) {
    if (icone.startsWith('01')) return '☀️';
    if (icone.startsWith('09') || icone.startsWith('10')) return '🌧️';
    return '☁️';
  }

  String dicaDoClima(double temp, String icone) {
    if (icone.startsWith('09') ||
        icone.startsWith('10') ||
        icone.startsWith('11')) {
      return 'Vai chover — cuidado com pisos escorregadios!';
    }
    if (temp >= 30) return 'Calor forte — beba bastante água!';
    if (temp <= 15) return 'Está frio — se sair, leve um agasalho!';
    return 'Bom dia para uma caminhada leve!';
  }
}
