// modelo do remedio, salvo no hive como map pra nao precisar de adapter
class Remedio {
  String nome;
  String dose;
  String horario;
  bool tomadoHoje;

  Remedio({
    required this.nome,
    required this.dose,
    required this.horario,
    this.tomadoHoje = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'dose': dose,
      'horario': horario,
      'tomadoHoje': tomadoHoje,
    };
  }

  factory Remedio.fromMap(Map<dynamic, dynamic> map) {
    return Remedio(
      nome: map['nome'] ?? '',
      dose: map['dose'] ?? '',
      horario: map['horario'] ?? '',
      tomadoHoje: map['tomadoHoje'] ?? false,
    );
  }
}
