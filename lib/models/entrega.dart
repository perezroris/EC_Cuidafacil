// Modelo da camada AI Logistics Extension.
// Entrega também representa um atendimento chegando ao paciente.
enum TipoEntrega {
  medicamento,
  atendimentoDomiciliar,
  exameDomicilio,
  fisioterapia,
}

extension TipoEntregaInfo on TipoEntrega {
  String get titulo {
    switch (this) {
      case TipoEntrega.medicamento:
        return 'Entrega de Medicamento';
      case TipoEntrega.atendimentoDomiciliar:
        return 'Atendimento Domiciliar';
      case TipoEntrega.exameDomicilio:
        return 'Exame em Domicílio';
      case TipoEntrega.fisioterapia:
        return 'Fisioterapia';
    }
  }

  String get emoji {
    switch (this) {
      case TipoEntrega.medicamento:
        return '💊';
      case TipoEntrega.atendimentoDomiciliar:
        return '🩺';
      case TipoEntrega.exameDomicilio:
        return '🧪';
      case TipoEntrega.fisioterapia:
        return '🏃';
    }
  }

  String get nomeAgente {
    switch (this) {
      case TipoEntrega.medicamento:
        return 'Entregador';
      case TipoEntrega.atendimentoDomiciliar:
        return 'Profissional de saúde';
      case TipoEntrega.exameDomicilio:
        return 'Técnico de coleta';
      case TipoEntrega.fisioterapia:
        return 'Fisioterapeuta';
    }
  }

  double get velocidadeMediaKmh {
    switch (this) {
      case TipoEntrega.medicamento:
        return 28;
      case TipoEntrega.atendimentoDomiciliar:
        return 22;
      case TipoEntrega.exameDomicilio:
        return 22;
      case TipoEntrega.fisioterapia:
        return 18;
    }
  }
}

enum StatusEntrega {
  solicitado,
  confirmado,
  aCaminho,
  proximo,
  concluido,
  cancelado,
}

extension StatusEntregaInfo on StatusEntrega {
  String get titulo {
    switch (this) {
      case StatusEntrega.solicitado:
        return 'Solicitado';
      case StatusEntrega.confirmado:
        return 'Confirmado';
      case StatusEntrega.aCaminho:
        return 'A caminho';
      case StatusEntrega.proximo:
        return 'Quase chegando';
      case StatusEntrega.concluido:
        return 'Concluído';
      case StatusEntrega.cancelado:
        return 'Cancelado';
    }
  }
}

class Entrega {
  final String id;
  final TipoEntrega tipo;
  final String descricao;
  StatusEntrega status;

  final double latOrigem;
  final double lngOrigem;
  final double latDestino;
  final double lngDestino;

  double latAtual;
  double lngAtual;

  final DateTime horarioSolicitacao;
  DateTime? horarioConcluido;

  int etaMinutos;
  final int etaMinutosOriginal;
  double distanciaKm;
  int confiancaModelo;

  bool houveImprevisto;
  String? mensagemImprevisto;

  Entrega({
    required this.id,
    required this.tipo,
    required this.descricao,
    required this.status,
    required this.latOrigem,
    required this.lngOrigem,
    required this.latDestino,
    required this.lngDestino,
    required this.latAtual,
    required this.lngAtual,
    required this.horarioSolicitacao,
    required this.etaMinutos,
    required this.etaMinutosOriginal,
    required this.distanciaKm,
    required this.confiancaModelo,
    this.horarioConcluido,
    this.houveImprevisto = false,
    this.mensagemImprevisto,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tipo': tipo.name,
      'descricao': descricao,
      'status': status.name,
      'latOrigem': latOrigem,
      'lngOrigem': lngOrigem,
      'latDestino': latDestino,
      'lngDestino': lngDestino,
      'latAtual': latAtual,
      'lngAtual': lngAtual,
      'horarioSolicitacao': horarioSolicitacao.toIso8601String(),
      'horarioConcluido': horarioConcluido?.toIso8601String(),
      'etaMinutos': etaMinutos,
      'etaMinutosOriginal': etaMinutosOriginal,
      'distanciaKm': distanciaKm,
      'confiancaModelo': confiancaModelo,
      'houveImprevisto': houveImprevisto,
      'mensagemImprevisto': mensagemImprevisto,
    };
  }

  factory Entrega.fromMap(Map<dynamic, dynamic> map) {
    return Entrega(
      id: map['id'],
      tipo: TipoEntrega.values.firstWhere((t) => t.name == map['tipo']),
      descricao: map['descricao'] ?? '',
      status: StatusEntrega.values.firstWhere((s) => s.name == map['status']),
      latOrigem: map['latOrigem'],
      lngOrigem: map['lngOrigem'],
      latDestino: map['latDestino'],
      lngDestino: map['lngDestino'],
      latAtual: map['latAtual'],
      lngAtual: map['lngAtual'],
      horarioSolicitacao: DateTime.parse(map['horarioSolicitacao']),
      horarioConcluido: map['horarioConcluido'] != null
          ? DateTime.parse(map['horarioConcluido'])
          : null,
      etaMinutos: map['etaMinutos'],
      etaMinutosOriginal: map['etaMinutosOriginal'],
      distanciaKm: map['distanciaKm'],
      confiancaModelo: map['confiancaModelo'],
      houveImprevisto: map['houveImprevisto'] ?? false,
      mensagemImprevisto: map['mensagemImprevisto'],
    );
  }
}
