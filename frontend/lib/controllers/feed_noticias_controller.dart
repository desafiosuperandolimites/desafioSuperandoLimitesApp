part of 'env_controllers.dart';

class FeedNoticiaController with ChangeNotifier {
  final FeedNoticiaService _feedNoticiaService = FeedNoticiaService();
  List<FeedNoticia> _feedNoticiaList = [];
  FeedNoticia? _selectedFeedNoticia;

  List<FeedNoticia> get feedNoticiaList => _feedNoticiaList;
  FeedNoticia? get selectedFeedNoticia => _selectedFeedNoticia;

  // Fetch all news feed items
  Future<void> fetchFeedNoticias() async {
    try {
      _feedNoticiaList = await _feedNoticiaService.getFeedNoticias();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching news feed items: $e');
      }
    }
  }

  // Fetch a specific news feed item by ID
  Future<void> fetchFeedNoticiaById(int id) async {
    try {
      _selectedFeedNoticia = await _feedNoticiaService.getFeedNoticiaById(id);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching news feed item: $e');
      }
    }
  }

  // Create a new news feed item
  Future<void> createFeedNoticia(
      BuildContext context, FeedNoticia newFeedNoticia) async {
    try {
      await _feedNoticiaService.createFeedNoticia(newFeedNoticia);
      await fetchFeedNoticias();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating news feed item: $e');
      }
      rethrow;
    }
  }

  // Update an existing news feed item
  Future<void> updateFeedNoticia(
      BuildContext context, int id, FeedNoticia updatedFeedNoticia) async {
    try {
      await _feedNoticiaService.updateFeedNoticia(id, updatedFeedNoticia);
      await fetchFeedNoticias();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating news feed item: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      rethrow;
    }
  }

  // Delete a news feed item
  Future<void> deleteFeedNoticia(BuildContext context, int id) async {
    try {
      await _feedNoticiaService.deleteFeedNoticia(id);
      await fetchFeedNoticias();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting news feed item: $e');
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
      rethrow;
    }
  }

  Future<String> gerarLinkCompartilhamento(int idNoticia) async {
    try {
      // Chama o Service que gera/retorna o shareUrl
      final shareUrl = await _feedNoticiaService.getShareLink(idNoticia);
      return shareUrl;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao gerar link de compartilhamento: $e');
      }
      rethrow;
    }
  }

  Future<FeedNoticia?> fetchNoticiaByShareToken(String shareToken) async {
    try {
      final noticia = await _feedNoticiaService.getNoticiaByShareToken(shareToken);
      return noticia;
    } catch (e) {
      if (kDebugMode) {
        print('Erro ao buscar notícia por shareToken: $e');
      }
      return null;
    }
  }
}
