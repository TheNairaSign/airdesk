import 'package:url_launcher/url_launcher.dart';

class UrlLauncherService {

  // Launch URL in external browser
  static Future<void> launchInBrowser() async {
    final Uri url = Uri.parse("https://x.com/Airdesk_link?t=qKczUp_QGNzZcCGmpLCe-w&s=09");
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  // Launch URL in in-app browser
  static Future<void> launchInAppBrowser() async {
    final Uri url = Uri.parse("https://x.com/Airdesk_link?t=qKczUp_QGNzZcCGmpLCe-w&s=09");
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
        enableJavaScript: true,
        enableDomStorage: true,
      ),
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
