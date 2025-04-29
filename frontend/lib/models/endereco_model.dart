class Endereco {
  final int id;
  final String cep;
  final String uf;
  final String cidade;
  final String logradouro;
  final String? complemento;
  final String bairro;
  final int? numero;

  Endereco({
    required this.id,
    required this.cep,
    required this.uf,
    required this.cidade,
    required this.logradouro,
    this.complemento,
    required this.bairro,
    required this.numero,
  });

  factory Endereco.fromJson(Map<String, dynamic> json) {
    return Endereco(
      id: json['ID'] ?? 0, // Use a default value of 0 if ID is null
      cep: json['CEP'] ?? '', // Handle missing field with a default value
      uf: json['UF'] ?? '', // Handle missing field with a default value
      cidade: json['CIDADE'] ?? '', // Handle missing field with a default value
      logradouro:
          json['LOGRADOURO'] ?? '', // Handle missing field with a default value
      complemento: json['COMPLEMENTO'], // Nullable
      bairro: json['BAIRRO'] ?? '', // Handle missing field with a default value
      numero: json['NUMERO'], // Handle missing field with a default value
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'CEP': cep,
      'UF': uf,
      'CIDADE': cidade,
      'LOGRADOURO': logradouro,
      'COMPLEMENTO': complemento,
      'BAIRRO': bairro,
      'NUMERO': numero,
    };
  }
}
