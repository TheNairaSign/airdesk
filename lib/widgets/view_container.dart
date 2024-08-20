// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:air_desk/components/qr_scanner.dart';
import 'package:air_desk/pages/qr_data_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;

class ViewContainer extends StatelessWidget {
  const ViewContainer({super.key});

  Future<void> fetchData(BuildContext context, String deskId) async {
    final url = 'https://airdesk-server.onrender.com/api/desk/$deskId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // Extracting content, images, and code
      var content = data["data"]["text"];
      var imagesList = data["data"]["images"];
      var imageUrl = imagesList.isNotEmpty ? imagesList[0]["url"] : null;  // Ensure there's an image URL
      var imageName = imagesList.isNotEmpty ? imagesList[0]["originalName"] : null;  // Ensure there's an image URL
      final dataCode = data["data"]["code"];
      String extractedValue = dataCode.replaceAll('"', ''); // Removing quotes if necessary
    
      debugPrint("extracted Value: $extractedValue");
      debugPrint(data.toString());

      // Navigate to the QrDataPage with the extracted values
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => QrDataPage(
            data: jsonEncode(extractedValue), 
            content: content, 
            imageUrl: imageUrl,
            imageName: imageName,
          ),
        ),
      );
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final containerWidth = MediaQuery.of(context).size.width;
    const borderColor = Color(0xffd5eefa);
    const borderWidth = 2.0;
    final viewController = TextEditingController();

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
                  onSubmitted: (deskId) {
                    fetchData(context, viewController.text);
                  },
                  controller: viewController,
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
  }
}

