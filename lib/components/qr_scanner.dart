// ignore_for_file: unused_import
import 'package:air_desk/providers/share_provider.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import 'package:air_desk/api/api_service.dart';
import 'package:air_desk/pages/data_page/qr_data_page.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../providers/view_provider.dart';

class QrScanner extends StatefulWidget {
  const QrScanner({super.key});
  @override
  State<StatefulWidget> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  void saveOrDisplayFile(File file) {
    // For example, open the file with the appropriate app
    OpenFile.open(file.path);
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              cameraFacing: CameraFacing.back,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null) 
                ? Text('Barcode Type: ${result!.format} Data: ${result!.code}', style: Theme.of(context).textTheme.bodyLarge) 
                : Text('Scan a code', style: Theme.of(context).textTheme.bodyLarge),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    final apiProv = context.read<ViewProvider>();
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
      });
      if (result != null) {
        controller.pauseCamera();
        final res = result?.code;
        final Uri uri = Uri.parse(res!);
        String lastSegment = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
        debugPrint(result!.code.toString());
        debugPrint(lastSegment);
        controller.pauseCamera();
        apiProv.fetchData(context, lastSegment);
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
