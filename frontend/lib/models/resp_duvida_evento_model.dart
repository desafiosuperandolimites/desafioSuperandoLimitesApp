class RespostaDuvida {
  final int? id;
  final int idUsuario;
  final int idDuvidaEvento;
  final String resposta;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  RespostaDuvida({
    this.id,
    required this.idUsuario,
    required this.idDuvidaEvento,
    required this.resposta,
    this.criadoEm,
    this.atualizadoEm,
  });

  DateTime? parseDate(dynamic date) {
    if (date is String) {
      return DateTime.tryParse(date);
    } else if (date is DateTime) {
      return date;
    }
    return null;
  }

  factory RespostaDuvida.fromJson(Map<String, dynamic> json) {
    return RespostaDuvida(
      id: json['ID'],
      idUsuario: json['ID_USUARIO'],
      idDuvidaEvento: json['ID_DUVIDA_EVENTO'],
      resposta: json['RESPOSTA'],
      criadoEm:
          json['CRIADO_EM'] != null ? DateTime.parse(json['CRIADO_EM']) : null,
      atualizadoEm: json['ATUALIZADO_EM'] != null
          ? DateTime.parse(json['ATUALIZADO_EM'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'ID_USUARIO': idUsuario,
      'ID_DUVIDA_EVENTO': idDuvidaEvento,
      'RESPOSTA': resposta,
      'CRIADO_EM': criadoEm?.toIso8601String(),
      'ATUALIZADO_EM': atualizadoEm?.toIso8601String(),
    };

    return data;
  }
}
