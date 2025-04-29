part of 'env_services.dart';

class FeedNoticiaService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  // Fetch all news feed items from the backend
  Future<List<FeedNoticia>> getFeedNoticias() async {
    String? token = await _getToken();

    Uri uri = Uri.parse('$baseUrl/noticias/listar');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> feedNoticiaJson = jsonDecode(response.body);
      if (kDebugMode) {
        print(feedNoticiaJson);
      }
      return feedNoticiaJson.map((json) => FeedNoticia.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load news feed items');
    }
  }

  // Fetch a specific news feed item by ID
  Future<FeedNoticia> getFeedNoticiaById(int id) async {
    String? token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/noticias/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return FeedNoticia.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load news feed item');
    }
  }

  // Create a new news feed item
  Future<void> createFeedNoticia(FeedNoticia feedNoticia) async {
    String? token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/noticias/criar'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(feedNoticia.toJson()),
    );

    if (response.statusCode != 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'An unexpected error occurred';
      throw Exception(errorMessage);
    }
  }

  // Update an existing news feed item
  Future<void> updateFeedNoticia(int id, FeedNoticia feedNoticia) async {
    String? token = await _getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/noticias/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(feedNoticia.toJson()),
    );

    if (response.statusCode != 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      String errorMessage =
          responseBody['error'] ?? 'An unexpected error occurred';
      throw Exception(errorMessage);
    }
  }

  // Delete a news feed item
  Future<void> deleteFeedNoticia(int id) async {
    String? token = await _getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/noticias/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete news feed item');
    }
  }

  // Dentro da classe FeedNoticiaService
  Future<String> getShareLink(int noticiaId) async {
    String? token = await _getToken();

    // POST /noticias/:id/share (ou GET, dependendo de como você implementou)
    final response = await http.post(
      Uri.parse('$baseUrl/noticias/$noticiaId/share'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Espera que o backend retorne algo como { "shareUrl": "https://..." }
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      if (jsonBody.containsKey('shareUrl')) {
        return jsonBody['shareUrl'];
      } else {
        throw Exception(
            'Nenhum link de compartilhamento retornado pelo servidor.');
      }
    } else if (response.statusCode == 201) {
      // Se o backend retornar 201, e o body tiver shareUrl
      final Map<String, dynamic> jsonBody = jsonDecode(response.body);
      if (jsonBody.containsKey('shareUrl')) {
        return jsonBody['shareUrl'];
      } else {
        throw Exception(
            'Nenhum link de compartilhamento retornado pelo servidor.');
      }
    } else {
      throw Exception('Falha ao gerar link de compartilhamento');
    }
  }

  Future<FeedNoticia?> getNoticiaByShareToken(String shareToken) async {
    try {
      String? token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/noticias/token/$shareToken'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return FeedNoticia.fromJson(jsonDecode(response.body));
      } else {
        // 404 ou outro erro => retorne null ou lance exception
        return null;
      }
    } catch (e) {
      rethrow; // ou retorne null
    }
  }
}


