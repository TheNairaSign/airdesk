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
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider = ref.read(historyNotifierProvider.notifier);
      historyProvider.loadHistory();
      historyProvider.getHistoryItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyItems = ref.watch(historyNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
        color: GlobalColours(context).buttonColor,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onRefresh: () async {
          ref.read(historyNotifierProvider.notifier)..loadHistory()..getHistoryItems();
        },
        child: historyItems.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history_toggle_off_outlined,
                      size: 80,
                      color: isDark ? Colors.grey[800] : Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No recent history",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isDark ? Colors.grey[600] : Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Your viewed desks will appear here",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.grey[700] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : const Padding(
              padding: EdgeInsets.only(top: 20),
              child: HistoryContainer(),
            ),
    );
  }
}