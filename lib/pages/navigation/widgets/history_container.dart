import 'package:air_desk/pages/data_page/qr_data_page.dart';
import 'package:animate_do/animate_do.dart';
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
          padding: EdgeInsets.zero,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = historyItems[index];
            return FadeInUp(
              duration: const Duration(milliseconds: 400),
              delay: Duration(milliseconds: index * 50),
              child: HistoryItemWidget(item: item),
            );
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

    final isLive = item.type == 'live';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Status Logic
    final isExpired = timeLeft.isNegative;
    final statusColor = isExpired 
        ? (isDark ? Colors.grey[600] : Colors.grey) 
        : (isLive ? Colors.green : Colors.blue);
    final statusText = isExpired ? "Expired" : (isLive ? "Live Desk" : "Shared File");


    return GestureDetector(
      onTap: () async {
        final result = await ref.read(viewProvider.notifier).fetchData(item.code);
        
        result.fold(
          (failure) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(failure.message), backgroundColor: Colors.red),
              );
            }
          },
          (data) {
            if (context.mounted) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => QrDataPage(
                  content: data.text,
                  files: data.images,
                  data: data.code,
                  createdAt: data.createdAt ?? DateTime.now(),
                ),
              ));
            }
          }
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xff1e1e1e) : Colors.white,
          borderRadius: BorderRadius.circular(16),
           boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor!.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusText.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                 if (item.editCode != null && item.editCode != '') 
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                     child: const Row(
                      children: [
                         Icon(Icons.edit_outlined, size: 12, color: Colors.orange),
                         SizedBox(width: 4),
                         Text(
                            "EDIT ACCESS",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                         )
                      ],
                     ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                 Text(
                   item.code,
                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
                     fontFamily: "monospace",
                     fontWeight: FontWeight.bold,
                     letterSpacing: 1,
                     color: isDark ? Colors.white : Colors.black87
                   ),
                 ),
                 // Could move edit code here or keep it simple
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: isDark ? Colors.grey[500] : Colors.grey[400]),
                const SizedBox(width: 6),
                if (isExpired)
                  Text(
                    'Expired',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red[300]),
                  )
                else
                  Text(
                    ref.watch(historyNotifierProvider.notifier).formatDuration(timeLeft),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontWeight: FontWeight.w500
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
