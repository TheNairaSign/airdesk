// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:air_desk/api/api_service.dart';
import 'package:air_desk/components/qr_scanner.dart';
import 'package:air_desk/model/data_model.dart';
import 'package:air_desk/pages/qr_data_page.dart';
import 'package:air_desk/provider/code_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ViewContainer extends StatelessWidget {
  const ViewContainer({super.key});

  Future<void> fetchData(BuildContext context, String deskId) async {
  _showLoadingDialog(context);
  final url = 'https://airdesk-server.onrender.com/api/desk/$deskId';
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      debugPrint("The statusCode: ${response.statusCode}");
      var data = jsonDecode(response.body);
      final dataCode = data["data"]["code"];
      String extractedValue = dataCode.replaceAll('"', ''); // Removing quotes if necessary

      debugPrint("extracted Value: $extractedValue");
      debugPrint(data.toString());

      final ApiService apiService = ApiService();
      final airdeskData = await apiService.getdata(extractedValue, context);

      Navigator.of(context).pop(); // Close the loading dialog before navigation
      debugPrint("Switching page");
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QrDataPage(
            data: jsonEncode(extractedValue),
            content: airdeskData.text,
            imageUrl: airdeskData.imageUrl,
            fileName: airdeskData.imageName,
            imageLength: airdeskData.images.length,
            file: airdeskData.images,
          ),
        ),
      );
    } else {
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog(context);
    }
  } catch (e) {
    Navigator.of(context).pop(); // Close the loading dialog
    _showErrorDialog(context);  // Showing the error dialog for catching errors
    debugPrint('Error occurred: $e');  // Debug print the error for better understanding
  }
  }

  final loadingSpinKit = const SpinKitDualRing(color: Color(0xff0054ff), lineWidth: 2,);
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Getting data", style: GoogleFonts.poppins(color: const Color(0xff0054ff)),),
          content: SizedBox(
            height: 50,
            width: 30,
            child: loadingSpinKit,
            ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Invalid input", style: GoogleFonts.poppins(color: const Color(0xff0054ff))),
          content: Text("Failed to load data", style: GoogleFonts.poppins(color: Colors.black)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK", style: GoogleFonts.poppins(color: const Color(0xff0054ff))),
            ),
          ],
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width;
    const borderColor = Color(0xffd5eefa);
    const borderWidth = 2.0;

    return Consumer<CodeProvider>(builder: (context, cP, child) {
      return Container(
        height: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xffECFcFA),
          border: Border.all(color: borderColor, width: borderWidth),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.south_west, color: Colors.grey[800], size: 16),
                const SizedBox(width: 3),
                Text(
                  "To view",
                  style: GoogleFonts.poppins(
                    color: Colors.grey[700],
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: containerWidth - 110,
                  child: TextField(
                    onSubmitted: (deskId) async {
                      await fetchData(context, cP.viewController.text);
                    },
                    controller: cP.viewController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.transparent,
                      hintText: "Paste code here or scan QR code",
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 18,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    debugPrint("QR Scanner");
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const QrScanner(),
                      ),
                    );
                  },
                  child: SvgPicture.asset("assets/svg/qr-scan.svg"),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
