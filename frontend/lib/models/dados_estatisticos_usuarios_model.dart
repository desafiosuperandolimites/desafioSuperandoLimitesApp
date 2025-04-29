class DadosEstatisticosUsuarios {
  final int id;
  final int idUsuarioInscrito;
  final int idUsuarioCadastra;
  final int? idUsuarioAprova;
  final int idEvento;
  final double kmPercorrido;
  final String? foto;
  final DateTime dataAtividade;
  final int? semana;
  final int idStatusDadosEstatisticos;
  final String? observacao;

  DadosEstatisticosUsuarios({
    required this.id,
    required this.idUsuarioInscrito,
    required this.idUsuarioCadastra,
    this.idUsuarioAprova,
    required this.idEvento,
    required this.kmPercorrido,
    this.foto,
    required this.dataAtividade,
    this.semana,
    required this.idStatusDadosEstatisticos,
    this.observacao,
  });

  factory DadosEstatisticosUsuarios.fromJson(Map<String, dynamic> json) {
    return DadosEstatisticosUsuarios(
      id: json['ID'],
      idUsuarioInscrito: json['ID_USUARIO_INSCRITO'],
      idUsuarioCadastra: json['ID_USUARIO_CADASTRA'],
      idUsuarioAprova: json['ID_USUARIO_APROVA'],
      idEvento: json['ID_EVENTO'],
      kmPercorrido: json['KM_PERCORRIDO'].toDouble(),
      foto: json['FOTO'],
      dataAtividade: DateTime.parse(json['DATA_ATIVIDADE']),
      semana: json['SEMANA'],
      idStatusDadosEstatisticos: json['ID_STATUS_DADOS_ESTATISTICOS'],
      observacao: json['OBSERVACAO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_USUARIO_INSCRITO': idUsuarioInscrito,
      'ID_USUARIO_CADASTRA': idUsuarioCadastra,
      'ID_USUARIO_APROVA': idUsuarioAprova,
      'ID_EVENTO': idEvento,
      'KM_PERCORRIDO': kmPercorrido,
      'FOTO': foto,
      'DATA_ATIVIDADE': dataAtividade.toIso8601String(),
      'SEMANA': semana,
      'ID_STATUS_DADOS_ESTATISTICOS': idStatusDadosEstatisticos,
      'OBSERVACAO': observacao,
    };
  }
}
