import 'package:air_desk/components/copy.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

class EditCodeContainer extends StatelessWidget {
  final String editCode;

  const EditCodeContainer({super.key, required this.editCode});


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: GlobalColours(context).containerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              "Edit Code (For creators only)",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            // Code display with Copy button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? Theme.of(context).scaffoldBackgroundColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // The code
                  Text(
                    editCode,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.2,
                      color: GlobalColours(context).codeTextColor,
                    ),
                  ),

                  // Copy Button
                  Copy(textToCopy: editCode, textColor: GlobalColours(context).codeTextColor,)
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Footer text
            Text(
              "Use this code edit your live desk content later",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
