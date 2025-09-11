// ignore_for_file: deprecated_member_use

import 'package:air_desk/pages/main_page/widgets/code_container.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:air_desk/widgets/airdesk_and_logo.dart';
import 'package:air_desk/widgets/edit_code_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QRDisplayPage extends StatelessWidget {
  const QRDisplayPage({super.key, required this.data, required this.code, this.editCode});
  final String data, code;
  final String? editCode;


  @override
  Widget build(BuildContext context) {
    final cp = context.read<ShareProvider>();
    final shareController = cp.shareController;
    return WillPopScope(
      onWillPop: () async {
        shareController.clear();
        return true;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0, 
            forceMaterialTransparency: true,
            actionsPadding: const EdgeInsets.only(right: 15),
            // actions: [
            //   if (editCode != null)
            //   Container(
            //     height: 23,
            //     padding: const EdgeInsets.symmetric(horizontal: 8),
            //     decoration: BoxDecoration(
            //       color: Colors.greenAccent,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Center(child: Text('Live desk', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green[900]),)),
            //   )
            // ],
          ),
          body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const AirdeskAndLogo(),
              const SizedBox(height: 10),
              Center(
                child: CodeContainer(code: code)
                ),
              const SizedBox(height: 30),
              Center(
                child: QrImageView(
                  backgroundColor: Colors.white,
                  data: data,
                  version: 3,
                  size: 250.0,
                ),
              ),
              const SizedBox(height: 10),
              Center(child: Text("Scan QR code to view content on your device", style: Theme.of(context).textTheme.bodyLarge)),
              if (editCode != null) ... [
                const SizedBox(height: 10),
                EditCodeContainer(editCode: editCode!)
              ]
            ],
          ),
        ),
      ),
    );
  }
}
