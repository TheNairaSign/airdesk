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
  Widget build(BuildContext context) {
    final submissions = ref.watch(myDeskProvider).myDeskData?.submissions;
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextButton.icon(
              iconAlignment: IconAlignment.end,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                backgroundColor: GlobalColours(context).containerColor,
                foregroundColor: GlobalColours(context).textColorForContainer,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.refresh, size: 15,),
              label: Text('Refresh', style:  Theme.of(context).textTheme.bodyMedium?.copyWith(),),
              onPressed: () {
                setState(() {
                  _creatorDeskDataFuture = ref.read(myDeskProvider.notifier).getCreatorDesks(load: false);
                });
              },
            ),
          ),
        ],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('MyDesk', style:  Theme.of(context).textTheme.headlineSmall?.copyWith(color: GlobalColours(context).textColorForContainer, fontWeight: FontWeight.bold),),
            const SizedBox(height: 5),
            Text('Your personal desk submissions', style:  Theme.of(context).textTheme.bodySmall?.copyWith(color: GlobalColours(context).textColorForContainer),),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
            isScrollable: true,
            indicatorColor: GlobalColours(context).buttonColor,
            unselectedLabelColor: Colors.grey,
            unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
            labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            labelColor: GlobalColours(context).buttonColor,
            tabs: [
              Text('Submissions (${submissions?.length ?? 0})'),
              const Text('Details'),
            ]),
      ),
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).popUntil((route) => route.settings.name == '/navigation');
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: FutureBuilder<MyDeskData?>(
            future: _creatorDeskDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SpinKitRing(color: GlobalColours(context).buttonColor, size: 50, lineWidth: 3);
              } 
              else if (snapshot.hasError) {
                debugPrint('Error in FutureBuilder: ${snapshot.error}');
                return Column(
                  children: [
                    Center(child: Text('Error: ${snapshot.error}')),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context)..pop()..push(MaterialPageRoute(
                          builder: (context) => const MyDeskPage(),
                        ));
                      },
                      child: Text(
                        'Try new different code', 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.blue, decoration: TextDecoration.underline)),
                    )
                  ],
                );
              } else {
                if (!snapshot.hasData || snapshot.data == null || snapshot.data!.myDesk == null) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(child: Text('No desk found. Please create or access a new desk.')),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: TextButton.styleFrom(
                          backgroundColor: GlobalColours(context).buttonColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const MyDeskPage(),
                          ));
                        },
                        child: Text(
                          'Try another code', 
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    ],
                  );
                }
                final deskData = snapshot.data!;
                final submissions = deskData.submissions;

                void onRefresh() {
                  setState(() {
                    _creatorDeskDataFuture = ref.read(myDeskProvider.notifier).getCreatorDesks(load: false);
                  });
                }

                final deskCode = deskData.myDesk!.code!;
                final adminCode = deskData.myDesk!.adminCode!;
        
                return TabBarView(
                  controller: _tabController,
                  children: [
                    SubmissionsTab(
                      onRefresh: onRefresh,
                      deskCode: deskCode,
                      submissions: submissions,
                      adminCode: adminCode,
                      isPremium: deskData.myDesk?.isPremium ?? false,
                      limit: deskData.myDesk?.submissionLimit,
                    ),
                    DeskDetailsPage(deskCode: deskCode, adminCode: adminCode)
                  ],
                );
              }
            },
          )
        ),
      )
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
      color: Colors.blue,
      onRefresh: () async => onRefresh(),
      child: ListView(
        children: [
          if (!isPremium) ...[
            Row(
              children: [
                Text(
                  '${limit?.used}/${limit?.monthly} per month',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                ),
                const Spacer(),
                SizedBox(
                  height: 30,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                      backgroundColor: const WidgetStatePropertyAll(primaryBlue),
                      foregroundColor: WidgetStatePropertyAll(GlobalColours(context).buttonTextColor),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    onPressed: () {
                      showDialog(context: context, builder: (context) => UpgradePopup(adminCode: adminCode));
                    },
                    child: Text(
                      'Get premium',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold))
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
          ],
          if (submissions != null && submissions!.isEmpty)
            const EmptyState()
          else
            Column(
              children: List.generate(submissions?.length ?? 0, (index) {
                return SubmissionListTile(submission: submissions![index]);
              }),
            )
        ],
      ),
    );
  }
}

class DeskDetailsPage extends StatelessWidget {
  const DeskDetailsPage({super.key, required this.deskCode, required this.adminCode});
  final String deskCode, adminCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Desk Details",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.bold, color: GlobalColours(context).textColorForContainer),
                ),
                const SizedBox(height: 4),
                Text(
                  "Your personal submission desk",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            SizedBox(
              height: 30,
              child: ElevatedButton(
                style: ButtonStyle(
                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 5, horizontal: 10)),
                  backgroundColor: WidgetStatePropertyAll(GlobalColours(context).buttonColor),
                  foregroundColor: WidgetStatePropertyAll(GlobalColours(context).buttonTextColor),
                  shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                ),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return BlurBackground(
                        blurX: 5,
                        blurY: 5,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: const BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('You can either share the desk code or the QR code to receive files and messages to your desk.',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: GlobalColours(context).textColorForContainer, fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                QrImageView(data: deskCode, size: 200, version: QrVersions.auto, backgroundColor: Colors.white),
                                EditCodeContainer(
                                  editCode: '@$deskCode',
                                  title: 'MyDesk Code',
                                  description: 'Share this code to receive files and messages to your desk',
                                  width: double.infinity,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  'Share desk',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Row for Public Code and Admin Code
        _CodeBox(
          title: "Admin Code",
          code: adminCode,
          textColor: Colors.red,
          color: Colors.red.withValues(alpha: .1),
          iconColor: Colors.red,
        ),

        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: GlobalColours(context).containerColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Upgrade to Premium', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: GlobalColours(context).textColorForContainer)),
                  const Spacer(),
                  SizedBox(
                    height: 20,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(context: context, builder: (context) => UpgradePopup(adminCode: adminCode));
                      },
                      child: Text(
                        'Upgrade',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: primaryBlue, fontWeight: FontWeight.bold),
                      )
                    ),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text('Get unlimited submissions, higher file limits, and priority support', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10))
            ]
          )
        )
      ],
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GlobalColours(context).containerColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: GlobalColours(context).textColorForContainer, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (!_obscureText)
              Copy(textToCopy: widget.code),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _obscureText ? '*********': widget.code,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.red, fontWeight: FontWeight.bold, fontFamily: "monospace"),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        child: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: widget.iconColor,
                          size: 15,
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


