import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../model/history_model.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/view_provider.dart';

class HistoryContainer extends ConsumerStatefulWidget {
  const HistoryContainer({super.key});

  @override
  ConsumerState<HistoryContainer> createState() => _HistoryContainerState();
}

class _HistoryContainerState extends ConsumerState<HistoryContainer> {
  @override
  void initState() {
    super.initState();
    final historyProvider = ref.read(historyNotifierProvider.notifier);
    historyProvider.loadHistory().then((_) {
      historyProvider.initializeTimer();
    });
  }
  @override
  Widget build(BuildContext context) {
    final historyItems = ref.watch(historyNotifierProvider);
    return historyItems.isEmpty
      ? Center(child: Text('No history yet.', style: Theme.of(context).textTheme.headlineSmall))
      : ListView.separated(
          itemCount: historyItems.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = historyItems[index];
            return HistoryItemWidget(item: item);
          },
        );
  }
}

class HistoryItemWidget extends ConsumerWidget {
  final HistoryItem item;

  const HistoryItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Calculate the time left for this specific item.
    final expiryTime = DateTime.parse(item.createdAt).add(const Duration(hours: 24));
    final timeLeft = expiryTime.difference(DateTime.now()); 

    debugPrint('Is live: ${item.type}');

    final isLive = item.type == 'live';

    final textColor = isLive ?  Colors.blue[700] : (codeColor);

    return GestureDetector(
      onTap: () {
        ref.watch(viewProvider.notifier).fetchData(item.code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).shadowColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  item.code,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (item.editCode != null && item.editCode != '') ...[
                  Icon(Icons.edit, size: 15, color: textColor),
                  const SizedBox(width: 5),
                  Text(
                    item.editCode!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: textColor, fontWeight: FontWeight.bold),
                  ),
                ]
              ],
            ),
            const SizedBox(height: 7),
            if (timeLeft.isNegative)
            Text(
              'Expired',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red),
            )
            else
            Text(
              ref.watch(historyNotifierProvider.notifier).formatDuration(timeLeft),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
