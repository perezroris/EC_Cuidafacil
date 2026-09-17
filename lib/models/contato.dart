class Contato {
  String nome;
  String telefone;

  Contato({required this.nome, required this.telefone});

  Map<String, dynamic> toMap() {
    return {'nome': nome, 'telefone': telefone};
  }

  factory Contato.fromMap(Map<dynamic, dynamic> map) {
    return Contato(nome: map['nome'] ?? '', telefone: map['telefone'] ?? '');
  }
}
