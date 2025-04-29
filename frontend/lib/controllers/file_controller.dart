part of 'env_controllers.dart';

class FileController {
  final FileService _fileService = FileService();
  File? downloadedFile;

  Future<void> uploadFileFotosPerfil(File? file) async {
    try {
      await _fileService.uploadFileFotosPerfil(file);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<void> uploadFileCapasEvento(File? file) async {
    try {
      await _fileService.uploadFileCapasEvento(file);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<void> uploadFileCapasNoticias(File? file) async {
    try {
      await _fileService.uploadFileCapasNoticias(file);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<void> uploadFileComprovantesKm(File? file) async {
    try {
      await _fileService.uploadFileComprovantesKm(file);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<void> uploadFileComprovantePagamento(File? file) async {
    try {
      await _fileService.uploadFileComprovantesPagamento(file);
    } catch (e) {
      if (kDebugMode) {
        print('Error uploading file: $e');
      }
      rethrow;
    }
  }

  Future<void> downloadFileFotosPerfil(String? fileName) async {
    try {
      downloadedFile = await _fileService.downloadFileFotosPerfil(fileName);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      rethrow;
    }
  }

  Future<void> downloadFileCapasEvento(String? fileName) async {
    try {
      downloadedFile = await _fileService.downloadFileCapasEvento(fileName);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      rethrow;
    }
  }

  Future<void> downloadFileCapasNoticias(String? fileName) async {
    try {
      downloadedFile = await _fileService.downloadFileCapasNoticias(fileName);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      rethrow;
    }
  }

  Future<void> downloadFileComprovantesKm(String? fileName) async {
    try {
      downloadedFile = await _fileService.downloadFileComprovantesKm(fileName);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      rethrow;
    }
  }

  Future<void> downloadFileComprovantesPagamento(String? fileName) async {
    try {
      downloadedFile = await _fileService.downloadFileComprovantesPagamento(fileName);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading file: $e');
      }
      rethrow;
    }
  }

}