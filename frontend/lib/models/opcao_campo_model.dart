class OpcaoCampo {
  final int? id;
  final int idCamposPersonalizados;
  String opcao;

  OpcaoCampo({
    this.id,
    required this.idCamposPersonalizados,
    required this.opcao,
  });

  factory OpcaoCampo.fromJson(Map<String, dynamic> json) {
    return OpcaoCampo(
      id: json['ID'],
      idCamposPersonalizados: json['ID_CAMPOS_PERSONALIZADOS'],
      opcao: json['OPCAO'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'ID_CAMPOS_PERSONALIZADOS': idCamposPersonalizados,
      'OPCAO': opcao,
    };

    return data;
  }
}
