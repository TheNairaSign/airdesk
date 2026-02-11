import 'package:dio/dio.dart';

class DownloadRepository {
  final Dio _dio = Dio();

  Future<void> downloadFile(String url, String path) async {
    await _dio.download(url, path);
  }

  Future<void> downloadMultipleFiles(List<String> urls) async {
    for (String url in urls) {
      final fileName = url.split('/').last;
      final path = "/storage/emulated/0/Download/$fileName";
      await _dio.download(url, path);
    }
  }

  Future<void> downloadAllFiles(List<Map<String, String>> files, Function(int, int) onProgress) async {
    int total = files.length;
    int completed = 0;

    for (var file in files) {
      await _dio.download(file['url']!, file['filename']!);
      completed++;
      onProgress(completed, total);
    }
  }


}
