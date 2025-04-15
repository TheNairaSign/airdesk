import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
  
  
  Future<void> openWebUrl() async {
    const url = "https://x.com/Airdesk_link?t=qKczUp_QGNzZcCGmpLCe-w&s=09";
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.inAppWebView);
      } else {
        throw Exception('Could not open URL: $url');
      }
    } catch (e) {
      debugPrint("Url Error: $e");
    }
  }
  