import 'dart:async';
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
  final borderColor = const Color(0xffd5eefa);
  // final borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        return ListView.separated(
          itemCount: historyProvider.historyItems.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            HistoryItem item = historyProvider.historyItems[index];
            return HistoryItemWidget(item: item, borderColor: borderColor, index: index,);
          },
        );
      },
    );
  }
}

class HistoryItemWidget extends StatefulWidget {
  final HistoryItem item;
  final Color borderColor;
  final int index;

  const HistoryItemWidget({
    super.key,
    required this.item,
    required this.borderColor,
    required this.index,
  });

  @override
  State<HistoryItemWidget> createState() => _HistoryItemWidgetState();
}

class _HistoryItemWidgetState extends State<HistoryItemWidget> {
  late Duration timeLeft;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    _initializeTimer();
  }

  void _initializeTimer() {
    DateTime createdAt = DateTime.parse(widget.item.createdAt);
    DateTime expiryTime = createdAt.add(const Duration(hours: 24));
    timeLeft = expiryTime.difference(DateTime.now());
    // final historyProvider = context.read<HistoryProvider>();

    if (timeLeft.isNegative) {
      timeLeft = Duration.zero;
    }

    // if (timeLeft == Duration.zero) {
    //   setState(() {
    //     historyProvider.historyItems.removeAt(widget.index);
    //   });
    // }

    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          timeLeft = timeLeft - const Duration(seconds: 1);
          if (timeLeft.isNegative) {
            timeLeft = Duration.zero;
            timer.cancel();
          }
        });
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = widget.item.code.replaceAll("", '');
    return GestureDetector(
      onTap: () async {
        debugPrint("Getting history data");
        final getData = context.read<ViewProvider>();
        getData.fetchData(context, widget.item.code);
        debugPrint("Getting history items");
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        width: double.infinity,
        height: 70,
        decoration: BoxDecoration(
          color: primaryGreen,
          border: Border.all(color: widget.borderColor, width: 1),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              code,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: codeColor, fontSize: 20),
            ),
            const SizedBox(height: 7),
            Text(
              formatDuration(timeLeft),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: codeColor, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
