class Grupo {
  final int? id; // O ID é opcional para permitir a criação de novos grupos
  final String nome;
  final String cnpj;
  final String? qtdUsuarios;
  final bool situacao;

  Grupo({
    this.id, // Torna o ID opcional
    required this.nome,
    required this.cnpj,
    this.qtdUsuarios,
    required this.situacao,
  });

  factory Grupo.fromJson(Map<String, dynamic> json) {
    return Grupo(
      id: json['ID'],
      nome: json['NOME'],
      cnpj: json['CNPJ'],
      qtdUsuarios: json['QTD_USUARIOS'],
      situacao: json['SITUACAO'],
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'NOME': nome,
      'CNPJ': cnpj,
      'QTD_USUARIOS': qtdUsuarios,
      'SITUACAO': situacao,
    };

    if (id != null) {
      data['ID'] = id!; // Apenas adiciona o ID se não for nulo
    }

    return data;
  }
}
