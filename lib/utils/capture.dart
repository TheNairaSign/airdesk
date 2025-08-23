import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> captureAndShare(GlobalKey boundaryKey) async {
  try {
    debugPrint('Capturing widget');
    await WidgetsBinding.instance.endOfFrame;
    
    final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    debugPrint('Boundary: $boundary');
    if (boundary == null) return;

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData?.buffer.asUint8List();

    if (pngBytes != null) {
      debugPrint('Png bytes not null: $pngBytes');
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = '${directory.path}/mydesk_share.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(pngBytes);

      await SharePlus.instance.share(ShareParams(
        files: [XFile(imagePath)],
        text: 'My Desk Share Card',
      ));
      // await imageFile.delete();
      // debugPrint('Image file deleted: $imagePath');
      debugPrint('Image file path: $imagePath');

    } else {
      debugPrint('Png bytes is null $pngBytes');
    }
  } catch (e) {
    debugPrint('Error capturing widget: $e');
    rethrow;
  }
}
