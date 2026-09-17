import 'package:dio/dio.dart';

class ServicoViaCep {
  final dio = Dio();

  Future<Map<String, String>?> buscarCep(String cep) async {
    try {
      final cepLimpo = cep.replaceAll(RegExp(r'[^0-9]'), '');
      if (cepLimpo.length != 8) return null;

      final response = await dio.get(
        'https://viacep.com.br/ws/$cepLimpo/json/',
      );

      if (response.data['erro'] == true) return null;

      return {
        'cidade': response.data['localidade'] ?? '',
        'estado': response.data['uf'] ?? '',
      };
    } catch (e) {
      return null;
    }
  }
}
