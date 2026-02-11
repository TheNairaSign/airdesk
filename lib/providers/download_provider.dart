import 'package:flutter/material.dart';
import '../repositories/download_repository.dart';

class DownloadProvider extends ChangeNotifier {
  final DownloadRepository _downloadRepository = DownloadRepository();

  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  double _progress = 0.0;
  double get progress => _progress;

  Future<bool> downloadFile(
    int index,
    List<bool> isDownloadingList,
    String url,
    String fileName,
  ) async {
    isDownloadingList[index] = true;
    notifyListeners();

    try {
      final path = "/storage/emulated/0/Download/$fileName";
      await _downloadRepository.downloadFile(url, path);
      isDownloadingList[index] = false;
      notifyListeners();
      return true;
    } catch (e) {
      isDownloadingList[index] = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> downloadFiles(List<String> urls) async {
    _isDownloading = true;
    notifyListeners();
    try {
      await _downloadRepository.downloadMultipleFiles(urls);
      _isDownloading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isDownloading = false;
      notifyListeners();
      return false;
    }
  }



  Future<void> downloadAllFiles(
      List<Map<String, String>> files, Function(int, int) onProgress) async {
    await _downloadRepository.downloadAllFiles(files, onProgress);
  }
}
