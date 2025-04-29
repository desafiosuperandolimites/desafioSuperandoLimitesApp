class PagamentoInscricao {
  final int? id;
  final int idUsuario;
  final int idInscricaoEvento;
  final int idDadosBancariosAdm;
  int idStatusPagamento; // Tornado mutável para ser atualizado
  final String comprovante;
  final DateTime dataPagamento;
  String? motivo; // Adicionando o campo 'motivo' para observação de rejeição

  PagamentoInscricao({
    this.id,
    required this.idUsuario,
    required this.idInscricaoEvento,
    required this.idDadosBancariosAdm,
    required this.idStatusPagamento,
    required this.comprovante,
    required this.dataPagamento,
    this.motivo, // Campo opcional
  });

  factory PagamentoInscricao.fromJson(Map<String, dynamic> json) {
    return PagamentoInscricao(
      id: json['ID'],
      idUsuario: json['ID_USUARIO'],
      idInscricaoEvento: json['ID_INSCRICAO_EVENTO'],
      idDadosBancariosAdm: json['ID_DADOS_BANCARIOS_ADM'],
      idStatusPagamento: json['ID_STATUS_PAGAMENTO'],
      comprovante: json['COMPROVANTE'],
      dataPagamento: DateTime.parse(json['DATA_PAGAMENTO']),
      motivo: json['MOTIVO'], // Adiciona o motivo na inicialização
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_USUARIO': idUsuario,
      'ID_INSCRICAO_EVENTO': idInscricaoEvento,
      'ID_DADOS_BANCARIOS_ADM': idDadosBancariosAdm,
      'ID_STATUS_PAGAMENTO': idStatusPagamento,
      'COMPROVANTE': comprovante,
      'DATA_PAGAMENTO': dataPagamento.toIso8601String(),
      'MOTIVO': motivo, // Inclui o motivo ao converter para JSON
    };
  }

  // Método para atualizar o status do pagamento
  void atualizarStatus(int novoStatus) {
    idStatusPagamento = novoStatus;
  }
}
