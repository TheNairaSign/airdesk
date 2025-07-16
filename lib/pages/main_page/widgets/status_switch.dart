// ignore_for_file: deprecated_member_use

import 'package:air_desk/constants.dart';
import 'package:flutter/material.dart';

class StatusSwitch extends StatefulWidget {
  const StatusSwitch({super.key});

  @override
  State<StatusSwitch> createState() => _StatusSwitchState();
}

class _StatusSwitchState extends State<StatusSwitch> {

  bool value = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => value = !value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 73,
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: value ? Colors.blue.withOpacity(0.15) : primaryGreen,
          borderRadius: BorderRadius.circular(30),
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
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
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
                  color: value ? Colors.blue : Colors.green,
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