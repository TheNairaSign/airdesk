// ignore_for_file: use_build_context_synchronously

import 'package:air_desk/components/copy.dart';
import 'package:air_desk/pages/main_page/my_desk/dialogs/access_dialog.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/utils/capture.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:air_desk/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyDeskCreatedPage extends StatefulWidget {
  const MyDeskCreatedPage({super.key});

  @override
  State<MyDeskCreatedPage> createState() => _MyDeskCreatedPageState();
}

class _MyDeskCreatedPageState extends State<MyDeskCreatedPage> {
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        forceMaterialTransparency: true,
        title:  Text(
          "Create MyDesk",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Consumer<MyDeskProvider>(
          builder: (context, myDeskProvider, child) {
            return Center(
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  // Success message
                  RepaintBoundary(
                    key: _boundaryKey,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: GlobalColours(context).containerColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 40),
                          const SizedBox(height: 10),
                          Text(
                            "MyDesk created successfully!",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Public Code
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your public MyDesk code:",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Center(
                                      child: Text(
                                        myDeskProvider.public ?? 'public',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Copy(textToCopy: myDeskProvider.public ?? 'public'),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Center(
                                child: QrImageView(
                                  backgroundColor: Colors.white,
                                  data: '@${myDeskProvider.public}',
                                  version: 3,
                                  size: 250.0,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Center(
                                child: Text(
                                  "QR Code for easy sharing – scan to send content to your desk",
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Admin Access Code
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              // color: GlobalColours(context).containerColor,
                              gradient: LinearGradient(colors: [
                                Colors.yellow[700]!,
                                Colors.yellow[500]!,
                                Colors.yellow[300]!,
                              ]),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.yellow[700]!, width: .5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Your admin access code:",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500, color: Colors.grey[900]),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  height: 40,
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.yellow[700]!, width: .5),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        myDeskProvider.admin ?? 'admin',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Copy(textToCopy: myDeskProvider.admin ?? 'admin'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Center(
                                  child: Text(
                                    "🔒 Keep this private! Use it to access your submissions",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12, color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          
                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.lightGreen,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () {
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => MyDeskCreatorPage(accessCode: myDeskProvider.admin)));
                                  showAccessDialog(context);
                                },
                                child: Text("Access Desk", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.green[900]),),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  try {
                                    await captureAndShare(_boundaryKey);
                                    snackBar('Share card saved successfully', context);
                                  } catch (error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to save share card: ${error.toString()}'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(10))
                                ),
                                child: Text("Save Share Card", style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}
