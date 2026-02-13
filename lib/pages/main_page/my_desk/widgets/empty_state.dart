import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
        const SizedBox(height: 16),
        const Text('No submissions yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Files shared to your desk will appear here', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}