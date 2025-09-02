import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../model/history_model.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/view_provider.dart';

class HistoryContainer extends StatefulWidget {
  const HistoryContainer({super.key});

  @override
  State<HistoryContainer> createState() => _HistoryContainerState();
}

class _HistoryContainerState extends State<HistoryContainer> {
  @override
  void initState() {
    super.initState();
    final historyProvider = Provider.of<HistoryProvider>(context, listen: false);
    historyProvider.loadHistory().then((_) {
      historyProvider.initializeTimer();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        if (historyProvider.historyItems.isEmpty) {
          return Center(child: Text('No history yet.', style: Theme.of(context).textTheme.headlineSmall,));
        }
        return ListView.separated(
          itemCount: historyProvider.historyItems.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = historyProvider.historyItems[index];
            return HistoryItemWidget(item: item);
          },
        );
      },
    );
  }
}

class HistoryItemWidget extends StatelessWidget {
  final HistoryItem item;

  const HistoryItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context, listen: true);

    // Calculate the time left for this specific item.
    final expiryTime = DateTime.parse(item.createdAt).add(const Duration(hours: 24));
    final timeLeft = expiryTime.difference(DateTime.now());

    debugPrint('Is live: ${item.type}');

    final isLive = item.type == 'live';

    final textColor = isLive ?  Colors.blue[700] : (codeColor);

    return GestureDetector(
      onTap: () {
        final viewProvider = context.read<ViewProvider>();
        viewProvider.fetchData(context, item.code);
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
              historyProvider.formatDuration(timeLeft),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
