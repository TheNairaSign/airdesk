import 'package:air_desk/constants.dart';
import 'package:air_desk/model/my_desk.dart';
import 'package:air_desk/model/submission.dart';
import 'package:air_desk/pages/main_page/my_desk/widgets/empty_state.dart';
import 'package:air_desk/pages/main_page/widgets/submission_item_tile.dart';
import 'package:air_desk/utils/upgrade_popup.dart';
import 'package:flutter/material.dart';

class SubmissionsTab extends StatelessWidget {
  const SubmissionsTab({
    super.key,
    required this.onRefresh,
    this.submissions,
    required this.deskCode,
    required this.adminCode,
    required this.isPremium,
    this.limit,
  });
  final VoidCallback onRefresh;
  final List<Submission>? submissions;
  final String deskCode, adminCode;
  final bool isPremium;
  final SubmissionLimit? limit;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: primaryBlue,
      onRefresh: () async => onRefresh(),
      child: CustomScrollView(
        slivers: [
          if (!isPremium)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: _buildPremiumBanner(context),
              ),
            ),

          if (submissions != null && submissions!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsRow(context),
              ),
            ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: (submissions == null || submissions!.isEmpty)
              ? const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: EmptyState()),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => SubmissionListTile(submission: submissions![index]),
                    childCount: submissions!.length,
                  ),
                ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final viewCount = submissions?.fold<int>(0, (prev, element) => prev + (element.viewCount ?? 0)) ?? 0;
    final fileCount = submissions?.fold<int>(0, (prev, element) => prev + (element.images?.length ?? 0)) ?? 0;

    return Row(
      children: [
        _buildStatCard(context, "Views", viewCount.toString(), Icons.remove_red_eye_rounded, Colors.orange),
        const SizedBox(width: 12),
        _buildStatCard(context, "Files", fileCount.toString(), Icons.file_present_rounded, Colors.teal),
        const SizedBox(width: 12),
        _buildStatCard(context, "Active", submissions?.length.toString() ?? "0", Icons.bolt_rounded, Colors.purple),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color.withValues(alpha: 0.6)),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFBF953F),
            Color(0xFFFCF6BA),
            Color(0xFFB38728),
            Color(0xFFFBF5B7),
            Color(0xFFAA771C),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB38728).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF4A340F), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upgrade to Premium',
                  style: TextStyle(color: Color(0xFF4A340F), fontWeight: FontWeight.w900, fontSize: 17),
                ),
                const SizedBox(height: 2),
                Text(
                  '${limit?.used}/${limit?.monthly} used this month',
                  style: TextStyle(
                    color: const Color(0xFF4A340F).withValues(alpha: 0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => showDialog(context: context, builder: (context) => UpgradePopup(adminCode: adminCode)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A340F),
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              minimumSize: const Size(80, 40),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Get', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}

