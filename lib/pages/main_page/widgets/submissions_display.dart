import 'package:air_desk/model/submission.dart';
import 'package:air_desk/pages/main_page/widgets/submission_item_tile.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

class SubmissionsDisplay extends StatelessWidget {
  const SubmissionsDisplay({super.key, this.submissions});
  final List<Submission>? submissions;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Submissions (${submissions?.length ?? 0})",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 40),
                
        if (submissions != null && submissions!.isEmpty) 
        const EmptyState()
        else 
        Expanded(
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: submissions?.length ?? 0, 
            separatorBuilder: (context, index) => const SizedBox(),
            itemBuilder: (context, index) {
              return SubmissionListTile(submission: submissions![index]);
            }, 
          ),
        ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: GlobalColours(context).containerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 10),
          Text(
            "No submissions yet",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "Share your code with others to receive content",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}