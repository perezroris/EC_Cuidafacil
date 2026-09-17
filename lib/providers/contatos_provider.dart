import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/contato.dart';

class ContatosProvider extends ChangeNotifier {
  List<Contato> listaContatos = [];

  final box = Hive.box('contatos');

  ContatosProvider() {
    carregarContatos();
  }

  void carregarContatos() {
    listaContatos = box.values
        .map((item) => Contato.fromMap(item as Map))
        .toList();
    notifyListeners();
  }

  Future<void> adicionarContato(Contato contato) async {
    if (listaContatos.length >= 5) return;
    await box.add(contato.toMap());
    carregarContatos();
  }

  Future<void> removerContato(int index) async {
    final key = box.keys.toList()[index];
    await box.delete(key);
    carregarContatos();
  }
}
