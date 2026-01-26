import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeskValidContainer extends StatelessWidget {
  const DeskValidContainer({super.key, required this.deskName});
  final String deskName;

  @override
  Widget build(BuildContext context) {
    return Consumer<MyDeskProvider>(
      builder: (context, myDeskProvider, child) {
        final exists = myDeskProvider.deskExists == true;
        final color = exists ? primaryBlue : Colors.red;
        final width = MediaQuery.of(context).size.width;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          constraints: BoxConstraints(maxWidth: width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: .5), width: 1)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  exists ? Icons.check_circle_outline : Icons.error_outline,
                  key: ValueKey(exists),
                  size: 16,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  exists ? 'Sending to: $deskName' : 'Desk "$deskName" not found',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        );
      }
    );
  }
}