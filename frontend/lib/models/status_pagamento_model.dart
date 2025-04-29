class StatusPagamento {
  final int? id;
  final String descricao;
  final String chaveNome;
  final bool situacao;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  StatusPagamento({
    this.id,
    required this.descricao,
    required this.chaveNome,
    this.situacao = true,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Factory constructor para criar uma instância de StatusPagamento a partir de JSON
  factory StatusPagamento.fromJson(Map<String, dynamic> json) {
    return StatusPagamento(
      id: json['ID'],
      descricao: json['DESCRICAO'],
      chaveNome: json['CHAVENOME'],
      situacao: json['SITUACAO'] ?? true,
      criadoEm:
          json['CRIADO_EM'] != null ? DateTime.parse(json['CRIADO_EM']) : null,
      atualizadoEm: json['ATUALIZADO_EM'] != null
          ? DateTime.parse(json['ATUALIZADO_EM'])
          : null,
    );
  }

  // Método para converter uma instância de StatusPagamento em JSON
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'DESCRICAO': descricao,
      'CHAVENOME': chaveNome,
      'SITUACAO': situacao,
    };

    // Adiciona os campos opcionais se eles não forem nulos
    if (id != null) {
      data['ID'] = id;
    }
    if (criadoEm != null) {
      data['CRIADO_EM'] = criadoEm!.toIso8601String();
    }
    if (atualizadoEm != null) {
      data['ATUALIZADO_EM'] = atualizadoEm!.toIso8601String();
    }

    return data;
  }
}
