class CategoriaCaminhadaCorrida {
  final int id;
  final String distancia;
  final String chave;
  final String descricao;
  final bool situacao;

  CategoriaCaminhadaCorrida({
    required this.id,
    required this.distancia,
    required this.chave,
    required this.descricao,
    required this.situacao,
  });

  factory CategoriaCaminhadaCorrida.fromJson(Map<String, dynamic> json) {
    return CategoriaCaminhadaCorrida(
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
