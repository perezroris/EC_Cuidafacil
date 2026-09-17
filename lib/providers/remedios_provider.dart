import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/remedio.dart';

class RemediosProvider extends ChangeNotifier {
  List<Remedio> listaRemedios = [];

  final box = Hive.box('remedios');

  RemediosProvider() {
    carregarRemedios();
  }

  void carregarRemedios() {
    listaRemedios = box.values
        .map((item) => Remedio.fromMap(item as Map))
        .toList();
    listaRemedios.sort((a, b) => a.horario.compareTo(b.horario));
    notifyListeners();
  }

  Future<void> adicionarRemedio(Remedio remedio) async {
    await box.add(remedio.toMap());
    carregarRemedios();
  }

  Future<void> removerRemedio(int index) async {
    // A lista é ordenada, então o índice visual pode ser diferente da chave do Hive.
    final remedio = listaRemedios[index];
    final keys = box.keys.toList();
    for (final key in keys) {
      final map = box.get(key) as Map;
      if (map['nome'] == remedio.nome && map['horario'] == remedio.horario) {
        await box.delete(key);
        break;
      }
    }
    carregarRemedios();
  }

  Future<void> confirmarTomou(int index) async {
    final remedio = listaRemedios[index];
    final keys = box.keys.toList();
    for (final key in keys) {
      final map = box.get(key) as Map;
      if (map['nome'] == remedio.nome && map['horario'] == remedio.horario) {
        map['tomadoHoje'] = !(map['tomadoHoje'] ?? false);
        await box.put(key, map);
        break;
      }
    }
    carregarRemedios();
  }
}
