part of 'env_services.dart';

class FileService {
  final String? baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    return await AuthController().getToken();
  }

  Future<void> uploadFileFotosPerfil(File? file) async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files/upload/fotosPerfil'),
      );

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add file to request
      if (kDebugMode) {
        print('Adding image to request...');
      }
      request.files.add(await http.MultipartFile.fromPath('file', file!.path));

      // Send the request
      if (kDebugMode) {
        print('Sending request...');
      }
      final response = await request.send();

      // Check response status
      if (kDebugMode) {
        print('Response received with status code: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        if (kDebugMode) {
          print('Upload successful: $responseData');
        }
      } else {
        if (kDebugMode) {
          print('Failed to upload image. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during file upload: $e');
      }
    }

  }

  Future<void> uploadFileCapasEvento(File? file) async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files/upload/capasEvento'),
      );

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add file to request
      if (kDebugMode) {
        print('Adding image to request...');
      }
      request.files.add(await http.MultipartFile.fromPath('file', file!.path));

      // Send the request
      if (kDebugMode) {
        print('Sending request...');
      }
      final response = await request.send();

      // Check response status
      if (kDebugMode) {
        print('Response received with status code: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        if (kDebugMode) {
          print('Upload successful: $responseData');
        }
      } else {
        if (kDebugMode) {
          print('Failed to upload image. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during file upload: $e');
      }
    }

  }

  Future<void> uploadFileCapasNoticias(File? file) async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files/upload/capasNoticias'),
      );

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add file to request
      if (kDebugMode) {
        print('Adding image to request...');
      }
      request.files.add(await http.MultipartFile.fromPath('file', file!.path));

      // Send the request
      if (kDebugMode) {
        print('Sending request...');
      }
      final response = await request.send();

      // Check response status
      if (kDebugMode) {
        print('Response received with status code: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        if (kDebugMode) {
          print('Upload successful: $responseData');
        }
      } else {
        if (kDebugMode) {
          print('Failed to upload image. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during file upload: $e');
      }
    }

  }

  Future<void> uploadFileComprovantesKm(File? file) async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files/upload/comprovantesKm'),
      );

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add file to request
      if (kDebugMode) {
        print('Adding image to request...');
      }
      request.files.add(await http.MultipartFile.fromPath('file', file!.path));

      // Send the request
      if (kDebugMode) {
        print('Sending request...');
      }
      final response = await request.send();

      // Check response status
      if (kDebugMode) {
        print('Response received with status code: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        if (kDebugMode) {
          print('Upload successful: $responseData');
        }
      } else {
        if (kDebugMode) {
          print('Failed to upload image. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during file upload: $e');
      }
    }

  }

  Future<void> uploadFileComprovantesPagamento(File? file) async {
    try {
      String? token = await _getToken();
      if (token == null) return;

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/files/upload/comprovantesPagamento'),
      );

      // Add headers
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      });

      // Add file to request
      if (kDebugMode) {
        print('Adding image to request...');
      }
      request.files.add(await http.MultipartFile.fromPath('file', file!.path));

      // Send the request
      if (kDebugMode) {
        print('Sending request...');
      }
      final response = await request.send();

      // Check response status
      if (kDebugMode) {
        print('Response received with status code: ${response.statusCode}');
      }
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        if (kDebugMode) {
          print('Upload successful: $responseData');
        }
      } else {
        if (kDebugMode) {
          print('Failed to upload image. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during file upload: $e');
      }
    }

  }

  Future<File?> downloadFileFotosPerfil(String? fileName) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final url = '$baseUrl/files/download/fotosPerfil/$fileName';


      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );


      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print('File downloaded and saved to $filePath');
        }
        return file;
      } else {
        if (kDebugMode) {
          print('Failed to download file. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during download: $e');
      }
    }
    return null;
  }

  Future<File?> downloadFileCapasEvento(String? fileName) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final url = '$baseUrl/files/download/capasEvento/$fileName';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print('File downloaded and saved to $filePath');
        }
        return file;
      } else {
        if (kDebugMode) {
          print('Failed to download file. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during download: $e');
      }
    }
    return null;
  }

  Future<File?> downloadFileCapasNoticias(String? fileName) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final url = '$baseUrl/files/download/capasNoticias/$fileName';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print('File downloaded and saved to $filePath');
        }
        return file;
      } else {
        if (kDebugMode) {
          print('Failed to download file. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during download: $e');
      }
    }
    return null;
  }

  Future<File?> downloadFileComprovantesKm(String? fileName) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final url = '$baseUrl/files/download/comprovantesKm/$fileName';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        if (kDebugMode) {
          print('File downloaded and saved to $filePath');
        }
        return file;
      } else {
        if (kDebugMode) {
          print('Failed to download file. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during download: $e');
      }
    }
    return null;
  }

  Future<File?> downloadFileComprovantesPagamento(String? fileName) async {
    try {
      String? token = await _getToken();
      if (token == null) return null;

      final url = '$baseUrl/files/download/comprovantesPagamento/$fileName';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);        
        if (kDebugMode) {
          print('File downloaded and saved to $filePath');
        }
        return file;
      } else {
        if (kDebugMode) {
          print('Failed to download file. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during download: $e');
      }
    }
    return null;
  }  
}