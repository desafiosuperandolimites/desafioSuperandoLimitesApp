part of 'views/env.dart';

Future<String?> getNomeBanco(String codigoBanco) async {
  try {
    final response = await http.get(
      Uri.parse('https://brasilapi.com.br/api/banks/v1/$codigoBanco'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['name'];
    } else {
      if (kDebugMode) {
        print('Erro na requisição: ${response.statusCode}');
      }
      return 'Erro ao acessar a API';
    }
  } catch (e) {
    if (kDebugMode) {
      print('Erro ao decodificar JSON: $e');
    }
    return 'Erro no formato de dados';
  }
}
