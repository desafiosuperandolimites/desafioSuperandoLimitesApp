class Evento {
  final int? id;
  final int idModalidadeEvento;
  final int idGrupoEvento;
  final int idPremiacaoEvento;
  final int idUsuario;
  final String nome;
  final String descricao;
  final String local;
  final String? capaEvento;
  final String dataInicioEvento;
  final String dataFimEvento;
  final bool isentoPagamento;
  final String dataInicioInscricoes;
  final String dataFimInscricoes;
  final double valorEvento;
  final bool situacao;
  bool isSubscribed;

  Evento({
    this.id,
    required this.idModalidadeEvento,
    required this.idGrupoEvento,
    required this.idPremiacaoEvento,
    required this.idUsuario,
    required this.nome,
    required this.descricao,
    required this.local,
    this.capaEvento,
    required this.dataInicioEvento,
    required this.dataFimEvento,
    required this.isentoPagamento,
    required this.dataInicioInscricoes,
    required this.dataFimInscricoes,
    required this.valorEvento,
    required this.situacao,
    this.isSubscribed = false,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['ID'],
      idModalidadeEvento: json['ID_MODALIDADE_EVENTO'],
      idGrupoEvento: json['ID_GRUPO_EVENTO'],
      idPremiacaoEvento: json['ID_PREMIACAO_EVENTO'],
      idUsuario: json['ID_USUARIO'],
      nome: json['NOME'],
      descricao: json['DESCRICAO'],
      local: json['LOCAL'],
      capaEvento: json['CAPA_EVENTO'],
      dataInicioEvento: json['DATA_INICIO_DESAFIO'],
      dataFimEvento: json['DATA_FIM_DESAFIO'],
      isentoPagamento: json['ISENTO_PAGAMENTO'],
      dataInicioInscricoes: json['DATA_INICIO_INSCRICAO'],
      dataFimInscricoes: json['DATA_FIM_INSCRICAO'],
      valorEvento: double.parse(json['VALOR_EVENTO']),
      situacao: json['SITUACAO'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_MODALIDADE_EVENTO': idModalidadeEvento,
      'ID_GRUPO_EVENTO': idGrupoEvento,
      'ID_PREMIACAO_EVENTO': idPremiacaoEvento,
      'ID_USUARIO': idUsuario,
      'NOME': nome,
      'DESCRICAO': descricao,
      'LOCAL': local,
      'CAPA_EVENTO': capaEvento,
      'DATA_INICIO_DESAFIO': dataInicioEvento,
      'DATA_FIM_DESAFIO': dataFimEvento,
      'ISENTO_PAGAMENTO': isentoPagamento,
      'DATA_INICIO_INSCRICAO': dataInicioInscricoes,
      'DATA_FIM_INSCRICAO': dataFimInscricoes,
      'VALOR_EVENTO': valorEvento,
      'SITUACAO': situacao,
    };
  }
}
