// ignore_for_file: deprecated_member_use

import 'package:air_desk/provider/code_provider.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/widgets/code_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRDisplayPage extends StatelessWidget {
  const QRDisplayPage({super.key, required this.data, required this.code});
  final String data, code;


  @override
  Widget build(BuildContext context) {
    final cp = context.read<CodeProvider>();
    final shareController = cp.shareController;
    return WillPopScope(
      onWillPop: () async {
        shareController.clear();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          body: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const AirdeskAndLogo(),
              const SizedBox(height: 30),
              Center(
                child: CodeContainer(code: cp.generatedCode,)
                ),
              const SizedBox(height: 40),
              Container(
                width: 360,
                height: 360,
                padding: const EdgeInsets.all(00),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: QrImageView(
                    data: data,
                    version: 3,
                    size: 350.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text("Scan QR code to view content on your device", style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }


}
