import 'package:air_desk/providers/view_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ViewField extends StatelessWidget {
  const ViewField({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * .65;
    return Consumer<ViewProvider>(
      builder: (context, viewProvider, child) {
        return Container(
          height: 50,
          padding: const EdgeInsets.all(7),
          margin: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          width: width,
          decoration: BoxDecoration(
            color: const Color(0xffEAFFFD),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xff069383), width: .5)
          ),
          child: Center(
            child: TextFormField(
              maxLength: 6,
              controller: viewProvider.sendCodeController,
              cursorColor: const Color(0xff069383),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xff069383), fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
                counterStyle: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[900]),
                contentPadding: const EdgeInsets.all(5),
                hintText: 'Paste QR code and enter to view',
                enabled: true,
                border: InputBorder.none
              ),
              onFieldSubmitted: (value) {
                viewProvider.fetchData(context, value);
              },
            ),
          ),
        );
      }
    );
  }
}