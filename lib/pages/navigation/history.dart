import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/history_provider.dart';
import '../../widgets/airdesk_and_logo.dart';
import 'widgets/history_container.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  @override
  void initState() {
    final historyProvider = context.read<HistoryProvider>();
    debugPrint("Loading history items");
    historyProvider.loadHistory();
    debugPrint("Getting history items");
    historyProvider.getHistoryItems();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          return Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const AirdeskAndLogo(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text("Share History", style: Theme.of((context)).textTheme.headlineSmall),
                    const SizedBox(width: 10),
                    Text('(Disappears in 24hrs)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                historyProvider.historyItems.isNotEmpty 
                ? const HistoryContainer()
                : Center(child: Text("No share history", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 25, color: Theme.of(context).textTheme.bodyLarge?.color))),
              ],
            ),
          );
        }
      ),
    );
  }
}