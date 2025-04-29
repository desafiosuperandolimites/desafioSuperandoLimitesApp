class FeedNoticia {
  final int? id;
  final int idUsuario;
  final String categoria;
  final String titulo;
  final String descricao;
  final String? fotoCapa;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  FeedNoticia({
    this.id,
    required this.idUsuario,
    required this.categoria,
    required this.titulo,
    required this.descricao,
    this.fotoCapa,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory FeedNoticia.fromJson(Map<String, dynamic> json) {
    return FeedNoticia(
      id: json['ID'],
      idUsuario: json['ID_USUARIO'],
      categoria: json['CATEGORIA'],
      titulo: json['TITULO'],
      descricao: json['DESCRICAO'],
      fotoCapa: json['FOTO_CAPA'],
      criadoEm:
          json['CRIADO_EM'] != null ? DateTime.parse(json['CRIADO_EM']) : null,
      atualizadoEm: json['ATUALIZADO_EM'] != null
          ? DateTime.parse(json['ATUALIZADO_EM'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_USUARIO': idUsuario,
      'CATEGORIA': categoria,
      'TITULO': titulo,
      'DESCRICAO': descricao,
      'FOTO_CAPA': fotoCapa,
    };
  }
}
