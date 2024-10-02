// ignore_for_file: unused_field

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../api/api_service.dart';
import '../utils/download_file.dart';
import '../model/image_model.dart';
import '../utils/get_file_path.dart';
import '../utils/snack_bar.dart';

class DownloadProvider extends ChangeNotifier {
  bool _isSuccess = false;
  bool _isDownloading = false;
  double _progress = 0.0;
  
  Future<void> downloadFile(
    BuildContext context,
    int index,
    List<bool> isDownloadingList,
    String url,
    String fileName,
    
  ) async {
      isDownloadingList[index] = true;
      notifyListeners();
    try {
      final dio = Dio();
      final fileName = url.split('/').last;
      final path ="/storage/emulated/0/Download/$fileName";
      await dio.download(
        url,
        path,
      ).then((_) {
        _isSuccess = true;
      });

      if (_isSuccess && context.mounted) {
        debugPrint("File download successful");
        snackBar("Download Successful", context);
      }
    } catch (e) {
      if (context.mounted) {
        debugPrint("Download Error: $e");
        snackBar("Error downloading file", context);
      }
    } finally {
        isDownloadingList[index] = false;
        notifyListeners();
    } 
  }
  Future<void> downloadFiles(
    BuildContext context,
    List<String> urls,
    
  ) async {
      notifyListeners();
    try {
      final dio = Dio();
      for (String url in urls) {
        final fileName = url.split('/').last;
        final path ="/storage/emulated/0/Download/$fileName";
        await dio.download(
          url,
          path,
        ).then((_) {
          _isSuccess = true;
        });
        }

      if (_isSuccess && context.mounted) {
        debugPrint("Downloaded all");
        snackBar("Download All successfully", context);
      }
    } catch (e) {
      if (context.mounted) {
        debugPrint("Download Error: $e");
        snackBar("Error downloading file", context);
      }
    } finally {
        notifyListeners();
    } 
  }


  Future<void> downloadMultiple(
    String url, 
    String fileName,
    BuildContext context,
    ) async {
    try {
      FileDownload().startDownloading(
          context,
          (receivedBytes, totalBytes) {
              _progress = receivedBytes / totalBytes;
              notifyListeners();
          },
          url,
          fileName,
          () {
              _isDownloading = false;
              notifyListeners();
          });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> downloadAllFiles(List<Map<String, String>> files, Function(int, int) onProgress) async {
    int total = files.length;
    int completed = 0;

    final dio = Dio();
    


    for (var file in files) {
      await dio.download(file['url']!, file['filename']!);
      completed++;
      // Update the progress for overall completion
      onProgress(completed, total);
    }
  }

}