import 'package:air_desk/components/copy.dart';
import 'package:flutter/material.dart';

class CodeContainer extends StatelessWidget {
  const CodeContainer({super.key, required this.code});
  final String code;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? Colors.white.withValues(alpha: 0.05) 
            : const Color(0xff069383).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode 
              ? Colors.white.withValues(alpha: 0.1) 
              : const Color(0xff069383).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SelectableText(
            code,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: const Color(0xff069383), 
              fontWeight: FontWeight.bold, 
              fontSize: 22,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 24,
            width: 1,
            color: isDarkMode ? Colors.white24 : Colors.black12,
          ),
          const SizedBox(width: 12),
          Copy(
            textToCopy: code,
          ),
          const SizedBox(width: 4),
          Text(
            'Copy',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}

