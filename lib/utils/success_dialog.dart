import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

void showSuccessDialog(BuildContext context, {
  required String deskName,
  required List<String> fileNames,
  required String content,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
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
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 20),
                  ),
                ],
              ),
            ),
            // Blue box
            Container(
              width: double.infinity,
              color: Colors.blue.withOpacity(0.05),
              padding: EdgeInsets.all(12),
              margin: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          child: Icon(Icons.check_circle, color: Colors.blue, size: 18),
                        ),
                        TextSpan(
                          text: "  Sent to MyDesk: ",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: deskName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(content, style: Theme.of(context).textTheme.bodySmall?.copyWith(),),
                  ),
                  SizedBox(height: 10), 
                  Row(
                    children: List.generate(fileNames.length > 3 ? 3 : fileNames.length, (index) {
                      return Chip(
                        label: Text(fileNames[index]),
                        avatar: Icon(Icons.insert_drive_file, size: 18, color: Colors.blue),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade300),
                      );
                    }),
                  )
                ],
              ),
            ),
            // Buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Close"),
                  ),
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text("Send Another"),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
