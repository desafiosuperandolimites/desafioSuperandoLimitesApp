class DuvidaEvento {
  final int? id;
  final int idUsuario;
  final String duvida;
  bool situacao;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  DuvidaEvento({
    this.id,
    required this.idUsuario,
    required this.duvida,
    required this.situacao,
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

  factory DuvidaEvento.fromJson(Map<String, dynamic> json) {
    return DuvidaEvento(
      id: json['ID'],
      idUsuario: json['ID_USUARIO'],
      duvida: json['DUVIDA'],
      situacao: json['SITUACAO'],
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
      'DUVIDA': duvida,
      'SITUACAO': situacao,
      'CRIADO_EM': criadoEm?.toIso8601String(),
      'ATUALIZADO_EM': atualizadoEm?.toIso8601String(),
    };

    return data;
  }
}
