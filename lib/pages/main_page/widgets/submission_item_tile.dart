import 'package:air_desk/constants.dart';
import 'package:air_desk/model/submission.dart';
import 'package:air_desk/pages/data_page/qr_data_page.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class SubmissionListTile extends StatelessWidget {
  final Submission submission;

  const SubmissionListTile({
    super.key,
    required this.submission,
  });

  @override
  Widget build(BuildContext context) {
    final colors = GlobalColours(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colors.containerColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _navigateToDetails(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, size: 12, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            formatDate(submission.createdAt ?? ''),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _StatItem(
                      icon: Icons.remove_red_eye_outlined,
                      label: submission.viewCount.toString(),
                    ),
                    if (submission.images != null && submission.images!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      _StatItem(
                        icon: Icons.image_outlined,
                        label: submission.images!.length.toString(),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  submission.text.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Code: ${submission.code}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.grey[500],
                        fontFamily: 'monospace',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryBlue, primaryBlue.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "View Details",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => QrDataPage(
        content: submission.text,
        files: submission.images,
        data: submission.code,
        createdAt: DateTime.parse(submission.createdAt!),
      ),
    ));
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String formatDate(String dateString) {
  final DateTime date = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('MMM d, y');
  final formattedTime = formatTime(dateString);
  final String formattedDate = formatter.format(date);
  return '$formattedDate, $formattedTime';
}

String formatTime(String dateString) {
  final DateTime date = DateTime.parse(dateString);
  final DateFormat formatter = DateFormat('h:mm a');
  return formatter.format(date);
}

