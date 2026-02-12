import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:air_desk/pages/data_page/qr_data_page.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'dart:io';

class QrScanner extends ConsumerStatefulWidget {
  const QrScanner({super.key});

  @override
  ConsumerState<QrScanner> createState() => _QrScannerState();
}

class _QrScannerState extends ConsumerState<QrScanner> {
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
                      ref.read(viewProvider.notifier).fetchData(lastSegment).then((result) {
                        result.fold(
                          (failure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
                            );
                             controller.start(); // Restart if failed? Or keep stopped? Maybe restart for retry.
                          },
                          (data) {
                            if (context.mounted) {
                              Navigator.of(context).pushReplacement(MaterialPageRoute(
                                builder: (context) => QrDataPage(
                                  content: data.text,
                                  files: data.images,
                                  data: data.code,
                                  createdAt: data.createdAt ?? DateTime.now(),
                                ),
                              ));
                            }
                          },
                        );
                      });
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