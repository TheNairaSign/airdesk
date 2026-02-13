import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:air_desk/components/copy.dart';

class _CodeBox extends StatefulWidget {
  final String title;
  final String code;
  final Color color;
  final Color iconColor;
  final Color textColor;

  const _CodeBox({
    required this.title,
    required this.code,
    required this.color,
    required this.textColor,
    required this.iconColor,
  });

  @override
  State<_CodeBox> createState() => _CodeBoxState();
}

class _CodeBoxState extends State<_CodeBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colors = GlobalColours(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.containerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textColorForContainer.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              if (!_obscureText) Copy(textToCopy: widget.code),
            ],
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => setState(() => _obscureText = !_obscureText),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: isDark ? 0.1 : 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _obscureText ? '••••••••••••' : widget.code,
                      style: TextStyle(
                        color: widget.textColor,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: widget.iconColor,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Export the widget with a public name since we can't export a private class
class CodeBox extends StatelessWidget {
  final String title;
  final String code;
  final Color color;
  final Color iconColor;
  final Color textColor;

  const CodeBox({
    required this.title,
    required this.code,
    required this.color,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return _CodeBox(
      title: title,
      code: code,
      color: color,
      textColor: textColor,
      iconColor: iconColor,
    );
  }
}