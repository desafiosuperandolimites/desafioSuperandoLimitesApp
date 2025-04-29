// models/resp_campo_personalizado_evento.dart

class RespCampoPersonalizadoEvento {
  final int? id;
  final int idCamposPersonalizados;
  final int idUsuario;
  final String respostaCampo;

  RespCampoPersonalizadoEvento({
    this.id,
    required this.idCamposPersonalizados,
    required this.idUsuario,
    required this.respostaCampo,
  });

  factory RespCampoPersonalizadoEvento.fromJson(Map<String, dynamic> json) {
    return RespCampoPersonalizadoEvento(
      id: json['ID'],
      idCamposPersonalizados: json['ID_CAMPOS_PERSONALIZADOS'],
      idUsuario: json['ID_USUARIO'],
      respostaCampo: json['RESPOSTA_CAMPO'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'ID_CAMPOS_PERSONALIZADOS': idCamposPersonalizados,
      'ID_USUARIO': idUsuario,
      'RESPOSTA_CAMPO': respostaCampo,
    };

    return data;
  }
}
