class DadosBancarios {
  final int? id;
  final int usuarioId; // ID do usuário
  final String agencia;
  final String conta;
  final String titular;
  final String banco;
  final String? pix; // O campo Pix é opcional
  final String? dataPagamento; // O campo de data de pagamento é opcional
  final DateTime dataAtualizacao;

  DadosBancarios({
    this.id,
    required this.usuarioId,
    required this.agencia,
    required this.conta,
    required this.titular,
    required this.banco,
    this.pix,
    this.dataPagamento,
    required this.dataAtualizacao,
  });

  factory DadosBancarios.fromJson(Map<String, dynamic> json) {
    return DadosBancarios(
      id: json['ID'],
      usuarioId: json['ID_USUARIO'],
      agencia: json['AGENCIA'],
      conta: json['CONTA'],
      titular: json['TITULAR'],
      banco: json['BANCO'],
      pix: json['PIX'],
      dataPagamento: json['DATA_PAGAMENTO'],
      dataAtualizacao: DateTime.parse(json['DATA_ATUALIZACAO']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ID_USUARIO': usuarioId,
      'AGENCIA': agencia,
      'CONTA': conta,
      'TITULAR': titular,
      'BANCO': banco,
      'PIX': pix,
      'DATA_PAGAMENTO': dataPagamento,
      'DATA_ATUALIZACAO': dataAtualizacao.toIso8601String(),
    };
  }
}
