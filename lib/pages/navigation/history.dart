import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/history_provider.dart';
// import '../../widgets/airdesk_and_logo.dart';
import 'widgets/history_container.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {

  @override
  void initState() {
    final historyProvider = ref.read(historyNotifierProvider.notifier);
    debugPrint("Loading history items");
    historyProvider.loadHistory();
    debugPrint("Getting history items");
    historyProvider.getHistoryItems();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final historyItems = ref.watch(historyNotifierProvider);
    return RefreshIndicator(
          color: GlobalColours(context).buttonColor,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          onRefresh: () async {
            ref.read(historyNotifierProvider.notifier)..loadHistory()..getHistoryItems();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              // const AirdeskAndLogo(),
              const SizedBox(height: 15),
              // Row(
              //   children: [
              //     Text("Share History", style: Theme.of((context)).textTheme.headlineSmall),
              //     const SizedBox(width: 10),
              //     Text('(Disappears in 24hrs)', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
              //   ],
              // ),
              // const SizedBox(height: 20),
              historyItems.isNotEmpty
              ? const HistoryContainer()
              : Center(child: Text("No share history", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 25, color: Theme.of(context).textTheme.bodyLarge?.color))),
            ],
          ),
        );
  }
}