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
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: GlobalColours(context).containerColor,
        borderRadius: BorderRadius.circular(15)
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        title: Row(
          children: [
            Text(
              formatDate(submission.createdAt ?? ''),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.circle, size: 4, color: Colors.grey),
            const SizedBox(width: 6),
            const Icon(Icons.remove_red_eye_outlined, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              submission.viewCount.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            submission.text.toString(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (submission.images!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.image_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 3),
                    Text(
                      submission.images!.length.toString(),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            if (submission.images != null && submission.images!.isNotEmpty) const SizedBox(width: 8),
            SizedBox(
              height: 27,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => QrDataPage(
                      content: submission.text,
                      files: submission.images,
                      data: submission.code,
                    ),
                  ));
                },
                icon: const Text("View"),
                label: const Icon(Icons.arrow_forward, size: 14),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
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

