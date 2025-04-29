class StatusDadosEstatisticos {
  final int id;
  final String descricao;
  final String chaveNome;
  final bool situacao;

  StatusDadosEstatisticos({
    required this.id,
    required this.descricao,
    required this.chaveNome,
    required this.situacao,
  });

  factory StatusDadosEstatisticos.fromJson(Map<String, dynamic> json) {
    return StatusDadosEstatisticos(
      id: json['ID'],
      descricao: json['DESCRICAO'],
      chaveNome: json['CHAVENOME'],
      situacao: json['SITUACAO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'DESCRICAO': descricao,
      'CHAVENOME': chaveNome,
      'SITUACAO': situacao,
    };
  }
}
