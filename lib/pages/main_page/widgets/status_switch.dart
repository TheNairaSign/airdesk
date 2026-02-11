// ignore_for_file: deprecated_member_use

import 'package:air_desk/constants.dart';
import 'package:air_desk/providers/share_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusSwitch extends ConsumerStatefulWidget {
  const StatusSwitch({super.key});

  @override
  ConsumerState<StatusSwitch> createState() => _StatusSwitchState();
}

class _StatusSwitchState extends ConsumerState<StatusSwitch> {

  bool value = false;

  // Toggle switch function to update value state
  void toggleSwitch() {
    setState(() {
      value = !value;
      ref.read(shareProvider.notifier).setIsLive(value);
    });
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => toggleSwitch(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 90,
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: value ? primaryBlue.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: value ? primaryBlue : Colors.grey.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: value ? 1.0 : 0.0,
                    child: const Text(
                      'Live',
                      style: TextStyle(
                        color: primaryBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: !value ? 1.0 : 0.0,
                    child: Text(
                      'Static',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Knob
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutBack,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: value ? primaryBlue : Colors.grey[400],
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  value ? Icons.wifi_tethering : Icons.wifi_off,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}