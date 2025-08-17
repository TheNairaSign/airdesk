import 'package:air_desk/constants.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

void showSuccessDialog(BuildContext context, {
  required String deskName,
  required List<String> fileNames,
  required String content,
  required VoidCallback onPop,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: GlobalColours(context).containerColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: EdgeInsets.zero,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Successfully Sent!",
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: GlobalColours(context).textColorForContainer
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onPop,
                    child: const Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            // Blue box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const WidgetSpan(
                          child: Icon(Icons.check_circle, color: primaryBlue, size: 18),
                        ),
                        TextSpan(
                          text: "  Sent to MyDesk: ",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: deskName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: primaryBlue),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    height: 40,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: GlobalColours(context).containerColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      content,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, 
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith()),
                  ),
                  const SizedBox(height: 10), 
                  Row(
                    children: [
                      const Icon(Icons.image, size: 15, color: primaryBlue),
                      const SizedBox(width: 5),
                      Text('${fileNames.length} files')
                    ],
                  )
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text("Send Another", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),),
                
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
