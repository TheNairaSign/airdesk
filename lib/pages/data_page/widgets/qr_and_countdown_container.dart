import 'package:air_desk/components/copy.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xff1e1e1e) : Colors.white,
        borderRadius: BorderRadius.circular(24),
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
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                   Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "LIVE",
                    style: TextStyle(
                      color: Colors.green[700],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: 'http://www.airdesk.me/view/${widget.code}',
                        version: QrVersions.auto,
                        size: 90.0,
                        gapless: false,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Colors.black,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            "Desk Expiring In",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            remaining,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: isDark ? Colors.white : const Color(0xFF006CFF),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _progressValue(),
                              minHeight: 6,
                              backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _progressValue() > 0.9 ? Colors.red : const Color(0xFF006CFF),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _formatDeadline(),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(
                  height: 1, 
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "DESK CODE",
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: isDark ? Colors.grey[500] : Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.code,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: "monospace",
                            letterSpacing: 2,
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 22,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFF006CFF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Copy(
                         textToCopy: widget.code,
                         textColor: isDark ? Colors.white70 : const Color(0xFF006CFF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
