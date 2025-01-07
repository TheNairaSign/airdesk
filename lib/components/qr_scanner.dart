import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'dart:io';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});

  @override
  State<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  MobileScannerController controller = MobileScannerController();
  Barcode? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                final apiProv = context.read<ViewProvider>();
                
                for (final barcode in barcodes) {
                  setState(() {
                    result = barcode;
                  });
                  
                  if (result != null) {
                    controller.stop();
                    final res = result?.rawValue;
                    if (res != null) {
                      final Uri uri = Uri.parse(res);
                      String lastSegment = uri.pathSegments.isNotEmpty 
                          ? uri.pathSegments.last 
                          : '';
                      debugPrint(res.toString());
                      debugPrint(lastSegment);
                      apiProv.fetchData(context, lastSegment);
                    }
                  }
                }
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                ? Text(
                    'Barcode Type: ${result!.type} Data: ${result!.rawValue}',
                    style: Theme.of(context).textTheme.bodyLarge
                  )
                : Text(
                    'Scan a code',
                    style: Theme.of(context).textTheme.bodyLarge
                  ),
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller.stop();
    }
    controller.start();
  }
}