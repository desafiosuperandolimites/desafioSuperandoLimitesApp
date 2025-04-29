class CampoPersonalizado {
  final int? id;
  final int idGruposEvento;
  final int idTipoCampo;
  final String nomeCampo;
  final bool obrigatorio;
  final bool situacao;

  CampoPersonalizado({
    this.id,
    required this.idGruposEvento,
    required this.idTipoCampo,
    required this.nomeCampo,
    required this.obrigatorio,
    required this.situacao,
  });

  factory CampoPersonalizado.fromJson(Map<String, dynamic> json) {
    return CampoPersonalizado(
      id: json['ID'],
      idGruposEvento: json['ID_GRUPOS_EVENTO'],
      idTipoCampo: json['ID_TIPO_CAMPO'],
      nomeCampo: json['NOME_CAMPO'],
      obrigatorio: json['OBRIGATORIO'],
      situacao: json['SITUACAO'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'ID_GRUPOS_EVENTO': idGruposEvento,
      'ID_TIPO_CAMPO': idTipoCampo,
      'NOME_CAMPO': nomeCampo,
      'OBRIGATORIO': obrigatorio,
      'SITUACAO': situacao,
    };

    return data;
  }
}
