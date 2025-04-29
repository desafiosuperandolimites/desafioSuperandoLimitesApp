class CategoriaBicicleta {
  final int id;
  final String distancia;
  final String chave;
  final String descricao;
  final bool situacao;

  CategoriaBicicleta({
    required this.id,
    required this.distancia,
    required this.chave,
    required this.descricao,
    required this.situacao,
  });

  factory CategoriaBicicleta.fromJson(Map<String, dynamic> json) {
    return CategoriaBicicleta(
      id: json['ID'],
      distancia: json['DISTANCIA'],
      chave: json['CHAVE'],
      descricao: json['DESCRICAO'],
      situacao: json['SITUACAO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'DISTANCIA': distancia,
      'CHAVE': chave,
      'DESCRICAO': descricao,
      'SITUACAO': situacao,
    };
  }
}
