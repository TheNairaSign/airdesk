import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../components/copy.dart';

class ContentContainer extends StatelessWidget {
  const ContentContainer({super.key, required this.content, required this.uri});
  final String? content;
  final Uri? uri;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 200,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.arrow_downward, size: 17, color: Colors.grey[700]),
              Text('Content',
                  style: GoogleFonts.poppins(color: Colors.grey[700])),
            ],
          ),
          const Divider(color: Colors.grey),
          const SizedBox(height: 15),
          if (content != null)
            Text(
              content!,
              style: Theme.of(context).textTheme.bodyLarge,
            )
          else
            Center(
              child: Text(
                "No content",
                style: GoogleFonts.poppins(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                ),
              ),
            ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(10),
                height: 50,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: primaryGreen,
                ),
                child: Copy(textToCopy: content ?? ""),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
