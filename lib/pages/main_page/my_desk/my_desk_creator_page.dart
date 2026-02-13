import 'package:air_desk/constants.dart';
import 'package:air_desk/model/my_desk.dart';
import 'package:air_desk/pages/main_page/my_desk/my_desk_page.dart';
import 'package:air_desk/pages/main_page/my_desk/widgets/submissions_tab.dart';
import 'package:air_desk/pages/main_page/my_desk/widgets/desk_details_page.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        elevation: 0,
        centerTitle: false,
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            'MyDesk',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colors.textColorForContainer,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _creatorDeskDataFuture = ref.read(myDeskProvider.notifier).getCreatorDesks(load: false);
              });
            },
            icon: Icon(Icons.refresh_rounded, color: colors.textColorForContainer),
          ),
          const SizedBox(width: 8),
        ],
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: colors.textColorForContainer,
                indicatorColor: primaryBlue,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                tabs: [
                  Tab(text: 'Submissions (${submissions?.length ?? 0})'),
                  const Tab(text: 'Desk Details'),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<MyDeskData?>(
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
                        SubmissionsTab(
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
                        DeskDetailsPage(deskCode: deskCode, adminCode: adminCode, deskData: deskData),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
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