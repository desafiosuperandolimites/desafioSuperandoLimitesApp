class Depoimento {
  final int? id;
  final int idUsuario;
  final String link;
  final bool situacao;

  Depoimento({
    this.id,
    required this.idUsuario,
    required this.link,
    required this.situacao,
  });

  factory Depoimento.fromJson(Map<String, dynamic> json) {
    return Depoimento(
      id: json['ID'],
      idUsuario: json['ID_USUARIO'],
      link: json['LINK'],
      situacao: json['SITUACAO'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'ID_USUARIO': idUsuario,
      'LINK': link,
      'SITUACAO': situacao,
    };
    return data;
  }
}
