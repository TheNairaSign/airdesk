// ignore_for_file: deprecated_member_use

import 'package:air_desk/constants.dart';
import 'package:air_desk/utils/global_colours.dart';
import 'package:flutter/material.dart';

void snackBar(String message, BuildContext context, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      showCloseIcon: true,
      backgroundColor: isError ? Colors.red[100] : GlobalColours(context).containerColor,
      content: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isError ? Colors.red : primaryBlue),
      ),
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(10),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
    ),
  );
}