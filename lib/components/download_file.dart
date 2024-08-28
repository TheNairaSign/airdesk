import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class FileDownload {
  Dio dio = Dio();
  bool isSuccess = false;

  void startDownloading(BuildContext context, final Function okCallback, String baseUrl, String filename, Function() isDownloading) async {
    debugPrint("Initiating download");
    String path = await _getFilePath(filename);
    try {
      await dio.download(
        baseUrl,
        path,
        onReceiveProgress: (recivedBytes, totalBytes) {
          okCallback(recivedBytes, totalBytes);
        },
        deleteOnError: true,
      ).then((_) {
        isSuccess = true;
      });
    } catch (e) {
      debugPrint("Exception: $e");
    }

    if (isSuccess && context.mounted) {
      debugPrint("Download Successful");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xffDFFCF8),
          content: Text("Downloaded All", style: GoogleFonts.poppins(color: Colors.black)),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          ),
      );
      isDownloading();
    } else {
      debugPrint("Download Unsuccesful");
    }
    }

    Future<String> _getFilePath(String filename) async {
    Directory? dir;

    try {
      if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory(); // for iOS
      } else {
        dir = Directory('/storage/emulated/0/Download/');  // for android
        if (!await dir.exists()) dir = (await getExternalStorageDirectory())!;
      }
    } catch (err) {
      print("Cannot get download folder path $err");
    }
    return "${dir?.path}$filename";
  }
}