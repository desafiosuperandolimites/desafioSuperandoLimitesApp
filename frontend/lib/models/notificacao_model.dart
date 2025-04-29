class Notificacao {
  final int id;
  final int idUsuario;
  final String title;
  final String body;
  final bool lida;
  final DateTime criadoEm;

  Notificacao({
    required this.id,
    required this.idUsuario,
    required this.title,
    required this.body,
    required this.lida,
    required this.criadoEm,
  });

  factory Notificacao.fromJson(Map<String, dynamic> json) {
    return Notificacao(
      id: json['ID'],
      idUsuario: json['ID_USUARIO'],
      title: json['TITLE'],
      body: json['BODY'],
      lida: json['LIDA'],
      criadoEm: DateTime.parse(json['CRIADO_EM']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'ID_USUARIO': idUsuario,
      'TITLE': title,
      'BODY': body,
      'LIDA': lida,
      'CRIADO_EM': criadoEm.toIso8601String(),
    };

    return data;
  }
}
