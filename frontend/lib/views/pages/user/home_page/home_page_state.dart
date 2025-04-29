part of '../../../env.dart';

Timer? _timer;
int currentPage = 0;
List<Grupo> grupos = [];
List<FeedNoticia> noticias = [];
List<Evento> eventos = [];
List<Evento> filteredEventos = [];
bool _isLoadingNoticias = true;
Map<int, File?> downloadedNoticiasImages = {};
Map<int, File?> downloadedEventosImages = {};
final FileController _fileController = FileController();
final PageController _pageController = PageController(viewportFraction: 1);

void _startAutoPlay() {
  _stopAutoPlay();
  _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
    if (_pageController.hasClients && noticias.isNotEmpty) {
      currentPage = (currentPage + 1) % noticias.length;
      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  });
}

void _stopAutoPlay() {
  _timer?.cancel();
}

Future<void> _downloadEventosImages() async {
  for (var evento in eventos) {
    if (evento.capaEvento != null && evento.capaEvento!.isNotEmpty) {
      try {
        await _fileController.downloadFileCapasEvento(evento.capaEvento!);
        downloadedEventosImages[evento.id!] = _fileController.downloadedFile;
      } catch (e) {
        downloadedEventosImages[evento.id!] = null;
        if (kDebugMode) {
          print('Erro ao baixar imagem do evento ${evento.id}: $e');
        }
      }
    } else {
      downloadedEventosImages[evento.id!] = null;
    }
  }
}

Future<void> _downloadNoticiasImages() async {
  for (var noticia in noticias) {
    if (noticia.fotoCapa != null && noticia.fotoCapa!.isNotEmpty) {
      try {
        await _fileController.downloadFileCapasNoticias(noticia.fotoCapa!);
        downloadedNoticiasImages[noticia.id!] = _fileController.downloadedFile;
      } catch (e) {
        downloadedNoticiasImages[noticia.id!] = null;
        if (kDebugMode) {
          print('Erro ao baixar imagem da notícia ${noticia.id}: $e');
        }
      }
    } else {
      downloadedNoticiasImages[noticia.id!] = null;
    }
  }
}

String getGrupoName(int? idGrupoEvento) {
  if (idGrupoEvento == null) {
    return 'Grupo não foi informado';
  }
  final grupo = grupos.firstWhere(
    (g) => g.id == idGrupoEvento,
    orElse: () => Grupo(
        id: 0, nome: 'Desconhecido', cnpj: '00000000000000', situacao: false),
  );
  return grupo.nome;
}

String _formatDateString(String dateString) {
  try {
    DateTime date = DateTime.parse(dateString);
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}';
  } catch (e) {
    if (kDebugMode) {
      print('Error parsing date: $e');
    }
    return '';
  }
}
