import 'package:air_desk/model/my_desk.dart';
import 'package:air_desk/pages/main_page/my_desk/my_desk_page.dart';
import 'package:air_desk/pages/main_page/widgets/submission_item_tile.dart';
import 'package:air_desk/pages/main_page/widgets/submissions_display.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:air_desk/widgets/edit_code_container.dart';
import 'package:blurbackground/blurbackground.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyDeskCreatorPage extends StatefulWidget {
  const MyDeskCreatorPage({super.key});

  @override
  State<MyDeskCreatorPage> createState() => _MyDeskCreatorPageState();
}

class _MyDeskCreatorPageState extends State<MyDeskCreatorPage> {

  late Future<MyDeskData?> _creatorDeskDataFuture;

  @override
  void initState() {
    super.initState();
    _creatorDeskDataFuture = Provider.of<MyDeskProvider>(context, listen: false).getCreatorDesks(context, load: false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                setState(() {
                  _creatorDeskDataFuture = Provider.of<MyDeskProvider>(context, listen: false).getCreatorDesks(context, load: false);
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
                return const SpinKitRing(color: Colors.blue, size: 50, lineWidth: 3);
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
        
                return RefreshIndicator(
                  color: Colors.blue,
                  onRefresh: () {
                    _creatorDeskDataFuture = Provider.of<MyDeskProvider>(context, listen: false).getCreatorDesks(context, load: false);
                    return _creatorDeskDataFuture;
                  },
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Submissions (${submissions?.length ?? 0})",
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStatePropertyAll(GlobalColours(context).buttonColor),
                              foregroundColor: WidgetStatePropertyAll(GlobalColours(context).buttonTextColor),
                              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            ),
                            onPressed: () {
                              final code = deskData.myDesk!.code!;
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
                                            QrImageView(data: code, size: 200, version: QrVersions.auto, backgroundColor: Colors.white),
                                            EditCodeContainer(
                                              editCode: code,
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
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (submissions != null && submissions.isEmpty) 
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
            },
          )
        ),
      )
    );
  }
}
