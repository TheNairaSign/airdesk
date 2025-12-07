import 'package:air_desk/components/copy.dart';
import 'package:air_desk/constants.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCountdownContainer extends StatefulWidget {
  final String title;
  final String code;
  final DateTime createdAt;

  const QrCountdownContainer({
    super.key,
    required this.title,
    required this.code,
    required this.createdAt,
  });

  @override
  State<QrCountdownContainer> createState() => _QrCountdownContainerState();
}

class _QrCountdownContainerState extends State<QrCountdownContainer> {
  late DateTime deadline;

  @override
  void initState() {
    super.initState();
    // ✅ Force deadline = createdAt + 24h
    print('CreatedAt: ${widget.createdAt}');
    deadline = widget.createdAt.add(const Duration(hours: 24));
    print('Deadline: $deadline');
  }

  String _formatRemainingTime() {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return "Expired";
    } else if (difference.inHours > 0) {
      return "${difference.inHours}h ${difference.inMinutes % 60}m left";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes}m ${difference.inSeconds % 60}s left";
    } else {
      return "${difference.inSeconds}s left";
    }
  }

  String _formatDeadline() {
    return DateFormat('MMM d, yyyy • hh:mm a').format(deadline);
  }

  double _progressValue() {
    final now = DateTime.now();
    const total = Duration(hours: 24);
    final elapsed = now.difference(widget.createdAt);

    if (elapsed.isNegative) return 0.0;
    if (elapsed > total) return 1.0;

    return elapsed.inSeconds / total.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _formatRemainingTime();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0,
      color: GlobalColours(context).containerColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   widget.title,
            //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 5),

            Row(
              children: [
                QrImageView(
                  backgroundColor: Colors.white,
                  data: 'http://www.airdesk.me/view/${widget.code}',
                  version: QrVersions.auto,
                  size: 100.0,
                ),
                const SizedBox(width: 20),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            remaining,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: _progressValue(),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Expires: ${_formatDeadline()}",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 5),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.code,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: primaryBlue, fontFamily: "monospace"),
                            ),
                            Copy(textToCopy: widget.code),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),

          ],
        ),
      ),
    );
  }
}
