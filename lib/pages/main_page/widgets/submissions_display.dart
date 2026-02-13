import 'package:air_desk/model/submission.dart';
import 'package:air_desk/pages/main_page/my_desk/widgets/empty_state.dart';
import 'package:air_desk/pages/main_page/widgets/submission_item_tile.dart';
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

