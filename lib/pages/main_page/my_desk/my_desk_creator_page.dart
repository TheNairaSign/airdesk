import 'package:air_desk/model/my_desk.dart';
import 'package:air_desk/pages/main_page/widgets/submission_item_tile.dart';
import 'package:air_desk/pages/main_page/widgets/submissions_display.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

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
        title: PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).popUntil((route) => route.settings.name == '/navigation');
              });
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MyDesk', style:  Theme.of(context).textTheme.headlineSmall?.copyWith(color: GlobalColours(context).textColorForContainer, fontWeight: FontWeight.bold),),
              const SizedBox(height: 5),
              Text('Your personal desk submissions', style:  Theme.of(context).textTheme.bodySmall?.copyWith(color: GlobalColours(context).textColorForContainer),),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: FutureBuilder<MyDeskData?>(
          future: _creatorDeskDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SpinKitRing(color: Colors.blue, size: 50, lineWidth: 3);
            } 
            else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } 
            else {
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
                    Text(
                      "Submissions (${submissions?.length ?? 0})",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
      )
    );
  }
}
