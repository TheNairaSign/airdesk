// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';


// class WebViewPage extends StatefulWidget {
//   const WebViewPage({super.key});

//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }

// class _WebViewPageState extends State<WebViewPage> {
//   late WebViewController controller;
//   bool isLoading = true;
//   String? error;

//   @override
//   void initState() {
//     super.initState();
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (url) => setState(() {
//             isLoading = true;
//             error = null;
//           }),
//           onPageFinished: (url) => setState(() => isLoading = false),
//           onWebResourceError: (error) => setState(() {
//             debugPrint("Error loading: ${error.description}");
//             this.error = error.description;
//             isLoading = false;
//           }),
//         ), 
//       )
//       ..loadRequest(Uri.parse("https://x.com/Airdesk_link?t=qKczUp_QGNzZcCGmpLCe-w&s=09"), 
//         headers: {
//           'Access-Control-Allow-Origin': '*',
//           'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
//           'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept',
//         },);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: Stack(
//         children: [
//           if (error != null)
//             Center(child: Text('Error: $error'))
//           else
//             WebViewWidget(controller: controller),
//           if (isLoading)
//             const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }