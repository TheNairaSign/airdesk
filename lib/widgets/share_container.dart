import 'package:air_desk/components/upload__file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ShareContainer extends StatefulWidget {
  const ShareContainer({super.key});

  @override
  State<ShareContainer> createState() => _ShareContainerState();
}

class _ShareContainerState extends State<ShareContainer> {

  @override
  Widget build(BuildContext context) {
    Color borderColor = const Color.fromRGBO(0, 108, 255, 0.1);
    final shareController = TextEditingController();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 225,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xffF2F7FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: 2.0),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.north_east,
                    color: Colors.grey[800],
                    size: 16,
                  ),
                  const SizedBox(
                    width: 3,
                  ),
                  Text(
                    "To Share",
                    style: GoogleFonts.poppins(
                        color: Colors.grey[700],
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        ),
                  )
                ],
              ),
              Expanded(
          flex: 50,
          child: TextField(
            controller: shareController,
            enableIMEPersonalizedLearning: true,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(
              fontSize: 18,
              overflow: TextOverflow.visible,
              fontWeight: FontWeight.normal,
              color: Colors.transparent,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(5),
              hintTextDirection: TextDirection.ltr,
              hintText: "Paste Link or text content here",
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[900]!.withOpacity(0.5),
                fontWeight: FontWeight.normal,
                fontSize: 18,
                ),
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.transparent,
              enabled: true,
              isDense: true,
            ),
          ),
        ),
        const UploadFile()
            ],
          ),
        ),

        Positioned(
          right: 30,
          bottom: -25,
          child: Container(
            padding: const EdgeInsets.all(13),
            height: 60,
            width: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xff0054ff),
            ),
            child: SvgPicture.asset("assets/svg/paper-plane.svg")),),
      ],
    );
  }
}
