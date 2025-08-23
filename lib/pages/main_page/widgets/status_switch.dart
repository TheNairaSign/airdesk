// ignore_for_file: deprecated_member_use

import 'package:air_desk/providers/share_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusSwitch extends StatefulWidget {
  const StatusSwitch({super.key});

  @override
  State<StatusSwitch> createState() => _StatusSwitchState();
}

class _StatusSwitchState extends State<StatusSwitch> {

  bool value = false;

  // Toggle switch function to update value state
  void toggleSwitch() {
    setState(() {
      value = !value;
      Provider.of<ShareProvider>(context, listen: false).setIsLive(value);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toggleSwitch(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 73,
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          // color: value ? Colors.blue.withOpacity(0.15) : primaryGreen,
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: value ? Colors.green : Colors.grey,
            width: .5,
          ),
        ),
        child: Stack(
          children: [
            // Label
            Align(
              alignment: value?  Alignment.centerLeft : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 5),
                child: Text(
                  value? 'Live' : 'Static',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: value ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Knob
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: value ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}