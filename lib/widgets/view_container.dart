import 'package:air_desk/components/qr_scanner.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';


class ViewContainer extends StatelessWidget {
  const ViewContainer({super.key});

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
        borderRadius: const BorderRadius.all(Radius.circular(10))
        ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.south_west, color: Colors.grey[800], size: 16,),
              const SizedBox(width: 3,),
              Text("To view", style: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 17, fontWeight: FontWeight.bold),)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: containerWidth - 110,
                child: TextField(
                  controller: viewController,
                  decoration: InputDecoration(
                    filled: true,
                    // contentPadding: EdgeInsets.all(0),
                    fillColor: Colors.transparent,
                    hintText: "Paste code here or scan QR code",
                    hintStyle: GoogleFonts.poppins(color: Colors.grey[700], fontSize: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    enabled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    )
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  debugPrint("QR Scanner");
                  // TODO: Call QR code APi
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const QrScanner()));
                  debugPrint("QR code");
                },
                child: SvgPicture.asset("assets/svg/qr-scan.svg"))
            ],
          ),
        ],
      ),
    );
  }
}