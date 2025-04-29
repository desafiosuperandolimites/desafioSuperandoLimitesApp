class Premiacao {
  final int? id;
  final String nome;
  final String descricao;
  final bool situacao;

  Premiacao({
    this.id,
    required this.nome,
    required this.descricao,
    required this.situacao,
  });

  factory Premiacao.fromJson(Map<String, dynamic> json) {
    return Premiacao(
      id: json['ID'],
      nome: json['NOME'],
      descricao: json['DESCRICAO'],
      situacao: json['SITUACAO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'NOME': nome,
      'DESCRICAO': descricao,
      'SITUACAO': situacao,
    };
  }
}
