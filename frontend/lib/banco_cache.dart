part of 'views/env.dart';

Future<Map<String, String>> loadBancosLocais() async {
  try {
    final String response = await rootBundle.loadString('assets/json/bancos.json');
    final Map<String, dynamic> data = json.decode(response);
    return data.map((key, value) => MapEntry(key, value.toString()));
  } catch (e) {
    if (kDebugMode) {
      print("Erro ao carregar JSON de ativos: $e");
    }
    return {};
  }
}

Future<void> atualizarBancosLocais() async {
  final prefs = await SharedPreferences.getInstance();
  final lastUpdate = prefs.getString('lastUpdate') ?? '';
  final now = DateTime.now().toString().split(' ')[0]; // Apenas a data

  if (lastUpdate != now) {
    try {
      final response = await http.get(Uri.parse('https://brasilapi.com.br/api/banks/v1'));
      if (response.statusCode == 200) {
        await prefs.setString('bancosJson', response.body);
        await prefs.setString('lastUpdate', now);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao atualizar dados de bancos: $e');
      }
    }
  }
}

Future<String?> getNomeBancoLocal(String codigoBanco) async {
  final bancos = await loadBancosLocais();
  return bancos[codigoBanco] ?? 'Banco não encontrado';
}
