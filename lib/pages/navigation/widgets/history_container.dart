import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../model/history_model.dart';
import '../../../providers/history_provider.dart';
import '../../../providers/view_provider.dart';

class HistoryContainer extends StatelessWidget {
  const HistoryContainer({super.key});

  final borderColor = const Color(0xffd5eefa);
  final borderWidth = 2.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        return ListView.separated(
          itemCount: historyProvider.historyItems.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (context, index) => const SizedBox(height:10),
          itemBuilder: (context, index) {
            HistoryItem item = historyProvider.historyItems[index];
            DateTime parsedDate = DateTime.parse(item.createdAt);
            String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(parsedDate);
            final code = item.code.replaceAll("", '');
            return GestureDetector(
              onTap: () async {
                debugPrint("Getting history data");
                final getData = context.read<ViewProvider>();
                getData.fetchData(context, item.code);
                debugPrint("Getting history items");
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                width: double.infinity,
                height: 85,
                decoration: BoxDecoration(
                  color: primaryGreen,
                  border: Border.all(color: borderColor, width: borderWidth),
                  borderRadius: const BorderRadius.all(Radius.circular(10))
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(code, style: GoogleFonts.poppins(color: codeColor, fontSize: 25),),
                    Text(formattedDate, style: GoogleFonts.poppins(color: codeColor, fontSize: 15),),
                  ],
                )
              ),
            );
          }
        );
      }
    );
  }
}