// ignore_for_file: deprecated_member_use

import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:air_desk/providers/view_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ViewField extends StatefulWidget {
  const ViewField({super.key});

  @override
  State<ViewField> createState() => _ViewFieldState();
}

class _ViewFieldState extends State<ViewField> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * .65;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final deskProvider = Provider.of<ViewProvider>(context);
    final sendToDesk = deskProvider.changeControllerState;

    return Consumer<ViewProvider>(
      builder: (context, viewProvider, child) {
        final deskExists = context.watch<MyDeskProvider>().deskExists == true;
        final color = deskExists ? primaryBlue : Colors.red;
        
        final colors = sendToDesk ? deskExists ? color : Colors.red : const Color(0xff069383);
        final backgroundColor = sendToDesk ? deskExists ? color.withOpacity(.1) : Colors.red.withOpacity(.1) : Colors.grey.withOpacity(.1);
        return Container(
          height: 40,
          // padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          width: width,
          decoration: BoxDecoration(
            // color: const Color(0xffEAFFFD),
            color: isDarkMode ? Theme.of(context).scaffoldBackgroundColor : backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: isDarkMode ? null : Border.all(color: colors, width: .5)

          ),
          child: Center(
            child: TextFormField(
              inputFormatters: [
                LengthLimitingTextInputFormatter(9),
              ],
              onChanged: (value) {
                setState(() {
                  viewProvider.deskNameListener(context);
                });
              },
              controller: viewProvider.sendCodeController,
              cursorColor: colors,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: colors, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(12),
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                hintText: 'Enter code to view/edit or @userDesk',
                enabled: true,
                border: InputBorder.none
              ),
              onFieldSubmitted: (value) {
                viewProvider.updateControllerState(context);
              },
            ),
          ),
        );
      }
    );
  }
}