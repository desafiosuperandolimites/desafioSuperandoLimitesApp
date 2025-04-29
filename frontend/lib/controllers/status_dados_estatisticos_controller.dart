part of 'env_controllers.dart';

class StatusDadosEstatisticosController with ChangeNotifier {
  final StatusDadosEstatisticosService _statusService = StatusDadosEstatisticosService();
  List<StatusDadosEstatisticos> _statusList = [];

  List<StatusDadosEstatisticos> get statusList => _statusList;

  Future<void> fetchStatusDadosEstatisticos() async {
    try {
      _statusList = await _statusService.getStatusDadosEstatisticos();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching StatusDadosEstatisticos: $e');
      }
    }
  }
}
