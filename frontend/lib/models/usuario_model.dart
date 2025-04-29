class Usuario {
  final int id;
  final String nome;
  final String email;
  final String? profissao;
  final String? celular;
  final String? cpf;
  final DateTime? dataNascimento;
  final String? fotoPerfil;
  final int? idGrupoEvento;
  final bool situacao;
  final bool cadastroPendente;
  final bool pagamentoPendente;
  final String? matricula;
  final String? problemaSaude;
  final String? atividadeFisicaRegular;
  final String? aplicativoAtividades;
  final int? idSexoTipo;
  final int? idEstadoCivilTipo;
  final int? idEndereco;
  final double? peso;
  final double? altura;
  final int? idTipoPerfil;

  Usuario({
    required this.id,
    required this.nome,
    required this.email,
    this.celular,
    this.profissao,
    this.cpf,
    this.dataNascimento,
    this.fotoPerfil,
    this.idGrupoEvento,
    required this.situacao,
    required this.cadastroPendente,
    required this.pagamentoPendente,
    this.matricula,
    this.problemaSaude,
    this.atividadeFisicaRegular,
    this.aplicativoAtividades,
    this.idSexoTipo,
    this.idEstadoCivilTipo,
    this.idEndereco,
    this.peso,
    this.altura,
    this.idTipoPerfil,
  });

  Usuario copyWith({
    int? id,
    String? nome,
    String? email,
    String? celular,
    String? cpf,
    DateTime? dataNascimento,
    String? fotoPerfil,
    int? idGrupoEvento,
    bool? situacao,
    bool? cadastroPendente,
    bool? pagamentoPendente,
    String? matricula,
    String? problemaSaude,
    String? atividadeFisicaRegular,
    String? aplicativoAtividades,
    int? idSexoTipo,
    int? idEstadoCivilTipo,
    int? idEndereco,
    double? peso,
    double? altura,
    int? idTipoPerfil,
  }) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      celular: celular ?? this.celular,
      cpf: cpf ?? this.cpf,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      fotoPerfil: fotoPerfil ?? this.fotoPerfil,
      idGrupoEvento: idGrupoEvento ?? this.idGrupoEvento,
      situacao: situacao ?? this.situacao,
      cadastroPendente: cadastroPendente ?? this.cadastroPendente,
      pagamentoPendente: pagamentoPendente ?? this.pagamentoPendente,
      matricula: matricula ?? this.matricula,
      problemaSaude: problemaSaude ?? this.problemaSaude,
      atividadeFisicaRegular:
          atividadeFisicaRegular ?? this.atividadeFisicaRegular,
      aplicativoAtividades: aplicativoAtividades ?? this.aplicativoAtividades,
      idSexoTipo: idSexoTipo ?? this.idSexoTipo,
      idEstadoCivilTipo: idEstadoCivilTipo ?? this.idEstadoCivilTipo,
      idEndereco: idEndereco ?? this.idEndereco,
      peso: peso ?? this.peso,
      altura: altura ?? this.altura,
      idTipoPerfil: idTipoPerfil ?? this.idTipoPerfil,
    );
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['ID'],
      nome: json['NOME'],
      email: json['EMAIL'],
      celular: json['CELULAR'],
      profissao: json['PROFISSAO'],
      cpf: json['CPF'],
      dataNascimento: json['DATA_NASCIMENTO'] != null
          ? DateTime.parse(json['DATA_NASCIMENTO'])
          : null,
      fotoPerfil: json['FOTO_PERFIL'],
      idGrupoEvento: json['ID_GRUPO_EVENTO'],
      situacao: json['SITUACAO'],
      cadastroPendente: json['CADASTRO_PENDENTE'],
      pagamentoPendente: json['PAGAMENTO_PENDENTE'],
      matricula: json['MATRICULA'],
      problemaSaude: json['PROBLEMA_SAUDE'],
      atividadeFisicaRegular: json['ATIVIDADE_FISICA_REGULAR'],
      aplicativoAtividades: json['APLICATIVO_ATIVIDADES'],
      idSexoTipo: json['ID_SEXO_TIPO'],
      idEstadoCivilTipo: json['ID_ESTADO_CIVIL_TIPO'],
      idEndereco: json['ID_ENDERECO'],
      peso: json['PESO'] != null ? double.tryParse(json['PESO']) : null,
      altura: json['ALTURA'] != null ? double.tryParse(json['ALTURA']) : null,
      idTipoPerfil: json['ID_PERFIL_TIPO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'NOME': nome,
      'EMAIL': email,
      'CELULAR': celular,
      'PROFISSAO': profissao,
      'CPF': cpf,
      'DATA_NASCIMENTO': dataNascimento?.toIso8601String(),
      'FOTO_PERFIL': fotoPerfil,
      'ID_GRUPO_EVENTO': idGrupoEvento,
      'SITUACAO': situacao,
      'CADASTRO_PENDENTE': cadastroPendente,
      'PAGAMENTO_PENDENTE': pagamentoPendente,
      'MATRICULA': matricula,
      'PROBLEMA_SAUDE': problemaSaude,
      'ATIVIDADE_FISICA_REGULAR': atividadeFisicaRegular,
      'APLICATIVO_ATIVIDADES': aplicativoAtividades,
      'ID_SEXO_TIPO': idSexoTipo,
      'ID_ESTADO_CIVIL_TIPO': idEstadoCivilTipo,
      'ID_ENDERECO': idEndereco,
      'PESO': peso,
      'ALTURA': altura,
      'ID_PERFIL_TIPO': idTipoPerfil,
    };
  }
}
