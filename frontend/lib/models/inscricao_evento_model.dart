class InscricaoEvento {
  final int? id;
  final int idUsuario;
  final int? idCategoriaBicicleta;
  final int? idCategoriaCaminhadaCorrida;
  final int idStatusInscricaoTipo;
  final int idEvento;
  final int meta;
  final bool termoCiente;
  bool medalhaEntregue;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  InscricaoEvento({
    this.id,
    required this.idUsuario,
    this.idCategoriaBicicleta,
    this.idCategoriaCaminhadaCorrida,
    required this.idStatusInscricaoTipo,
    required this.idEvento,
    required this.meta,
    required this.termoCiente,
    required this.medalhaEntregue,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Factory para criar um objeto InscricaoEvento a partir de um JSON
  factory InscricaoEvento.fromJson(Map<String, dynamic> json) {
    return InscricaoEvento(
      id: json['ID'],
      idUsuario: json['ID_USUARIO'],
      idCategoriaBicicleta: json['ID_CATEGORIA_BICICLETA'],
      idCategoriaCaminhadaCorrida: json['ID_CATEGORIA_CAMINHADA_CORRIDA'],
      idStatusInscricaoTipo: json['ID_STATUS_INSCRICAO_TIPO'],
      idEvento: json['ID_EVENTO'],
      meta: json['META'],
      medalhaEntregue: json['MEDALHA_ENTREGUE'],
      termoCiente: json['TERMO_CIENTE'] == 1 || json['TERMO_CIENTE'] == true,
      criadoEm:
          json['CRIADO_EM'] != null ? DateTime.parse(json['CRIADO_EM']) : null,
      atualizadoEm: json['ATUALIZADO_EM'] != null
          ? DateTime.parse(json['ATUALIZADO_EM'])
          : null,
    );
  }

  // Método para converter o objeto InscricaoEvento em JSON
  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_USUARIO': idUsuario,
      'ID_CATEGORIA_BICICLETA': idCategoriaBicicleta,
      'ID_CATEGORIA_CAMINHADA_CORRIDA': idCategoriaCaminhadaCorrida,
      'ID_STATUS_INSCRICAO_TIPO':
          idStatusInscricaoTipo, // Nome ajustado para consistência
      'ID_EVENTO': idEvento,
      'META': meta,
      'MEDALHA_ENTREGUE': medalhaEntregue,
      'TERMO_CIENTE': termoCiente ? 1 : 0, // Converte booleano para inteiro
      'CRIADO_EM': criadoEm?.toIso8601String(),
      'ATUALIZADO_EM': atualizadoEm?.toIso8601String(),
    };
  }
}
