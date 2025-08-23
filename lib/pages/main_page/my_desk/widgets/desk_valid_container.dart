import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/my_desk_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeskValidContainer extends StatelessWidget {
  const DeskValidContainer({super.key, required this.deskName});
  final String deskName;

  @override
  Widget build(BuildContext context) {
    return Consumer<MyDeskProvider>(
      builder: (context, myDeskProvider, child) {
        final color = myDeskProvider.deskExists == true ? primaryBlue : Colors.red;
        final width = MediaQuery.of(context).size.width;

        return Container(
          height: 30,
          constraints: BoxConstraints(maxWidth: width * 0.7),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: color, width: .7)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.work_outline_sharp, size: 12, color: color,),
              const SizedBox(width: 5),
              Text(myDeskProvider.deskExists == true ? 'Sending to myDesk: $deskName' : 'Desk: $deskName not found', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),)
            ],
          ),
        );
      }
    );
  }
}