import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/history_provider.dart';
import '../../widgets/airdesk_and_logo.dart';
import 'widgets/history_container.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {

  @override
  void initState() {
    final historyProvider = context.read<HistoryProvider>();
    debugPrint("Loading history items");
    historyProvider.loadHistory();
    debugPrint("Getting history items");
    historyProvider.getHistoryItems();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<HistoryProvider>(
        builder: (context, historyProvider, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 40, left: 15, right: 15, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AirdeskAndLogo(),
                  const SizedBox(height: 30),
                  historyProvider.historyItems.isNotEmpty 
                  ? const HistoryContainer() 
                  : Center(child: Text("No share history", style: GoogleFonts.poppins(color: Colors.black, fontSize: 25),),),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}