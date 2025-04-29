part of 'env_controllers.dart';

class StatusPagamentoController with ChangeNotifier {
  final StatusPagamentoService _statusPagamentoService =
      StatusPagamentoService();
  List<StatusPagamento> _statusPagamentoList = [];

  List<StatusPagamento> get statusPagamentoList => _statusPagamentoList;

  // Método para buscar todos os status de inscrição
  Future<void> fetchStatusPagamento() async {
    try {
      _statusPagamentoList = await _statusPagamentoService.getStatusPagamento();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching StatusPagamento: $e');
      }
    }
  }
}
