import 'package:air_desk/components/copy.dart';
import 'package:air_desk/constants.dart';
import 'package:air_desk/model/my_desk.dart';
import 'package:air_desk/pages/main_page/my_desk/my_desk_page.dart';
import 'package:air_desk/pages/main_page/widgets/submission_item_tile.dart';
import 'package:air_desk/pages/main_page/widgets/submissions_display.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:air_desk/widgets/edit_code_container.dart';
import 'package:blurbackground/blurbackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../model/submission.dart';
import '../../../utils/upgrade_popup.dart';

class MyDeskCreatorPage extends ConsumerStatefulWidget {
  const MyDeskCreatorPage({super.key});

  @override
  ConsumerState<MyDeskCreatorPage> createState() => _MyDeskCreatorPageState();
}

class _MyDeskCreatorPageState extends ConsumerState<MyDeskCreatorPage> with SingleTickerProviderStateMixin {
  late Future<MyDeskData?> _creatorDeskDataFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _creatorDeskDataFuture = Future(() => ref.read(myDeskProvider.notifier).getCreatorDesks(load: false));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final submissions = ref.watch(myDeskProvider).myDeskData?.submissions;
    final colors = GlobalColours(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).popUntil((route) => route.settings.name == '/navigation');
            });
          }
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 180,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: innerBoxIsScrolled ? 2 : 0,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      color: colors.containerColor,
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MyDesk',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: colors.textColorForContainer,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Manage your submissions and desk details',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colors.textColorForContainer.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.containerColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.refresh, size: 20),
                    ),
                    onPressed: () {
                      setState(() {
                        _creatorDeskDataFuture = ref.read(myDeskProvider.notifier).getCreatorDesks(load: false);
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.label,
                      indicatorColor: primaryBlue,
                      labelColor: primaryBlue,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
                      indicator: UnderlineTabIndicator(
                        borderSide: const BorderSide(width: 4.0, color: primaryBlue),
                        borderRadius: BorderRadius.circular(2),
                        insets: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      tabs: [
                        Tab(text: 'Submissions (${submissions?.length ?? 0})'),
                        const Tab(text: 'Desk Details'),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: FutureBuilder<MyDeskData?>(
            future: _creatorDeskDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: SpinKitFadingCube(
                    color: primaryBlue.withValues(alpha: 0.5),
                    size: 40,
                  ),
                );
              } else if (snapshot.hasError) {
                return _buildErrorState(context, snapshot.error);
              } else {
                final deskData = snapshot.data;
                if (deskData == null || deskData.myDesk == null) {
                  return _buildEmptyDeskState(context);
                }
                
                final deskCode = deskData.myDesk?.code ?? '';
                final adminCode = deskData.myDesk?.adminCode ?? '';

                return TabBarView(
                  controller: _tabController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: SubmissionsTab(
                        onRefresh: () {
                          setState(() {
                            _creatorDeskDataFuture = ref.read(myDeskProvider.notifier).getCreatorDesks(load: false);
                          });
                        },
                        deskCode: deskCode,
                        submissions: deskData.submissions,
                        adminCode: adminCode,
                        isPremium: deskData.myDesk?.isPremium ?? false,
                        limit: deskData.myDesk?.submissionLimit,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: DeskDetailsPage(deskCode: deskCode, adminCode: adminCode, deskData: deskData),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text('Something went wrong', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(error.toString(), textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyDeskPage()));
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
            child: const Text('Try Different Code'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDeskState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.desk_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text('No desk found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Create or access a new desk to get started', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyDeskPage()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Access Desk'),
          ),
        ],
      ),
    );
  }
}

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
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (!isPremium) _buildPremiumBanner(context),
          if (submissions == null || submissions!.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: EmptyState(),
            )
          else
            ...List.generate(submissions?.length ?? 0, (index) {
              return SubmissionListTile(submission: submissions![index]);
            }),
          const SizedBox(height: 100), // Spacing for bottom
        ],
      ),
    );
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade800, Colors.blue.shade600],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.star, color: Colors.amber, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Plan Status',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  '${limit?.used}/${limit?.monthly} submissions this month',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => showDialog(context: context, builder: (context) => UpgradePopup(adminCode: adminCode)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Upgrade', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class DeskDetailsPage extends StatelessWidget {
  const DeskDetailsPage({super.key, required this.deskCode, required this.adminCode, required this.deskData});
  final String deskCode, adminCode;
  final MyDeskData deskData;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShareCard(context),
          const SizedBox(height: 24),
          _buildCodeSection(context, "Admin Access", adminCode, true),
          const SizedBox(height: 24),
          _buildInfoSection(context),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildShareCard(BuildContext context) {
    final colors = GlobalColours(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colors.containerColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.share_outlined, size: 32, color: primaryBlue),
          ),
          const SizedBox(height: 16),
          const Text(
            "Share your Desk",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Allow others to send files and messages directly to you using your desk code.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], height: 1.5),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showShareSheet(context),
            icon: const Icon(Icons.qr_code_2, size: 20),
            label: const Text("Share Desk Code", style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeSection(BuildContext context, String title, String code, bool isSensitive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        _CodeBox(
          title: title,
          code: code,
          textColor: isSensitive ? Colors.red : primaryBlue,
          color: isSensitive ? Colors.red.withValues(alpha: 0.05) : primaryBlue.withValues(alpha: 0.05),
          iconColor: isSensitive ? Colors.red : primaryBlue,
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    final colors = GlobalColours(context);
    final isPremium = deskData.myDesk?.isPremium ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPremium ? Colors.amber.withValues(alpha: 0.05) : colors.containerColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPremium ? Colors.amber.withValues(alpha: 0.3) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                isPremium ? Icons.verified : Icons.info_outline,
                color: isPremium ? Colors.amber : primaryBlue,
              ),
              const SizedBox(width: 12),
              Text(
                isPremium ? "Premium Desk" : "Upgrade to Premium",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (!isPremium)
                TextButton(
                  onPressed: () => showDialog(context: context, builder: (context) => UpgradePopup(adminCode: adminCode)),
                  child: const Text("View Details", style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            isPremium 
              ? "You have full access to all premium features, including unlimited submissions and larger file limits."
              : "Get unlimited submissions, higher file size limits, and priority support with AirDesk Premium.",
            style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4),
          ),
        ],
      ),
    );
  }

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BlurBackground(
          blurX: 10,
          blurY: 10,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Share Desk',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Others can use this QR or code to send files.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: deskCode,
                    size: 180,
                    version: QrVersions.auto,
                  ),
                ),
                const SizedBox(height: 32),
                EditCodeContainer(
                  editCode: '@$deskCode',
                  title: 'Desk Code',
                  description: 'Used for quick access',
                  width: double.infinity,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CodeBox extends StatefulWidget {
  final String title;
  final String code;
  final Color color;
  final Color iconColor;
  final Color textColor;

  const _CodeBox({
    required this.title,
    required this.code,
    required this.color,
    required this.textColor,
    required this.iconColor,
  });

  @override
  State<_CodeBox> createState() => _CodeBoxState();
}

class _CodeBoxState extends State<_CodeBox> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colors = GlobalColours(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.containerColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const Spacer(),
              if (!_obscureText) Copy(textToCopy: widget.code),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _obscureText ? '••••••••••••' : widget.code,
                          style: TextStyle(
                            color: widget.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: _obscureText ? 2 : 0,
                            fontFamily: "monospace",
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: widget.iconColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}


