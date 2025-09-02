import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:share_plus/share_plus.dart'; // Not needed for download

    Future<String?> captureAndDownload(GlobalKey boundaryKey, {
      String? fileName,
      double pixelRatio = 3.0,
    }) async {
      try {
        debugPrint('Starting widget capture for download');

        // Ensure all frames are completed before capturing
        await WidgetsBinding.instance.endOfFrame;

        // Get the render boundary
        final context = boundaryKey.currentContext;
        if (context == null) {
          throw Exception(
              'GlobalKey context is null - widget may not be mounted');
        }

        final boundary = context.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) {
          throw Exception(
              'RenderRepaintBoundary not found - ensure widget is wrapped with RepaintBoundary');
        }

        debugPrint('Boundary found, capturing image...');

        // Capture the image
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ImageByteFormat.png);

        if (byteData == null) {
          throw Exception('Failed to convert image to byte data');
        }

        final pngBytes = byteData.buffer.asUint8List();
        debugPrint('Image captured successfully (${pngBytes.length} bytes)');

        // Get app documents directory (no permissions needed)
        final directory = await getApplicationDocumentsDirectory();
        debugPrint('Using directory: ${directory.path}');

        // Create unique filename
        final timestamp = DateTime
            .now()
            .millisecondsSinceEpoch;
        final imageName = fileName ?? 'airdesk_capture_$timestamp.png';
        final imagePath = '${directory.path}/$imageName';

        // Save the image
        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(pngBytes);

        debugPrint('Image saved successfully to: $imagePath');
        return imagePath;
      } catch (e) {
        debugPrint('Error in captureAndDownload: $e');
        rethrow;
      }
    }


// Alternative version that saves to external storage with permission handling
    Future<String?> captureAndDownloadToGallery(GlobalKey boundaryKey, {
      String? fileName,
      double pixelRatio = 3.0,
    }) async {
      try {
        debugPrint('Starting widget capture for gallery download');

        // For Android, we need to handle permissions differently based on API level
        if (Platform.isAndroid) {
          // Request notification permission first (this often helps with other permissions)
          await Permission.notification.request();

          // For saving to gallery/external storage, try different permissions
          PermissionStatus permissionStatus = PermissionStatus.denied;

          // Try photos permission first (works on Android 13+)
          permissionStatus = await Permission.photos.request();

          if (!permissionStatus.isGranted) {
            // Try storage permission (works on older Android)
            permissionStatus = await Permission.storage.request();
          }

          if (!permissionStatus.isGranted) {
            // Try manage external storage (Android 11+)
            permissionStatus = await Permission.manageExternalStorage.request();
          }

          debugPrint('Final permission status: $permissionStatus');

          if (!permissionStatus.isGranted) {
            throw Exception(
                'Storage permission denied. The image has been saved to app documents instead.');
          }
        }

        // Capture the widget (same logic as basic version)
        await WidgetsBinding.instance.endOfFrame;

        final context = boundaryKey.currentContext;
        if (context == null) {
          throw Exception(
              'GlobalKey context is null - widget may not be mounted');
        }

        final boundary = context.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) {
          throw Exception(
              'RenderRepaintBoundary not found - ensure widget is wrapped with RepaintBoundary');
        }

        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ImageByteFormat.png);

        if (byteData == null) {
          throw Exception('Failed to convert image to byte data');
        }

        final pngBytes = byteData.buffer.asUint8List();

        // Try to save to external storage/gallery
        Directory? directory;
        if (Platform.isAndroid) {
          // Try different external storage paths
          final externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            // Create Pictures/Airdesk directory
            directory = Directory('${externalDir.path}/../DCIM/Airdesk');
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
          }
        }

        // Fallback to app documents if external fails
        directory ??= await getApplicationDocumentsDirectory();

        final timestamp = DateTime
            .now()
            .millisecondsSinceEpoch;
        final imageName = fileName ?? 'airdesk_capture_$timestamp.png';
        final imagePath = '${directory.path}/$imageName';

        final imageFile = File(imagePath);
        await imageFile.writeAsBytes(pngBytes);

        debugPrint('Image saved to gallery/external: $imagePath');
        return imagePath;
      } catch (e) {
        debugPrint('Error in captureAndDownloadToGallery: $e');
        // Fallback to basic app documents save
        return await captureAndDownload(
            boundaryKey, fileName: fileName, pixelRatio: pixelRatio);
      }
    }

    Future<DownloadResult> captureAndDownloadWithResult(GlobalKey boundaryKey, {
      String? fileName,
      double pixelRatio = 3.0,
    }) async {
      try {
        final filePath = await captureAndDownload(
          boundaryKey,
          fileName: fileName,
          pixelRatio: pixelRatio,
        );
        return DownloadResult.success(filePath);
      } on Exception catch (e) {
        debugPrint('Capture and download failed: $e');
        return DownloadResult.failed(e.toString());
      }
    }

  class DownloadResult {
  final bool isSuccess;
  final String? filePath;
  final String? error;

  const DownloadResult.success(this.filePath)
      : isSuccess = true, error = null;

  const DownloadResult.failed(this.error)
      : isSuccess = false, filePath = null;
  }

// Usage example:
/*
class MyWidget extends StatelessWidget {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: YourContentWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final filePath = await captureAndDownload(_repaintBoundaryKey);
            if (filePath != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Image saved to: $filePath')),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to download: $e')),
            );
          }
        },
        child: Icon(Icons.download),
      ),
    );
  }
}

// Or using the result version:
/*
final result = await captureAndDownloadWithResult(_repaintBoundaryKey);
if (result.isSuccess) {
  print('Downloaded to: ${result.filePath}');
} else {
  print('Download failed: ${result.error}');
}
*/
*/