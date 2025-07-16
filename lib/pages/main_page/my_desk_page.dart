import 'package:air_desk/constants.dart';
import 'package:air_desk/themes/light_theme.dart';
import 'package:air_desk/utils/get_device_info.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyDeskPage extends StatefulWidget {
  const MyDeskPage({super.key});

  @override
  State<MyDeskPage> createState() => _MyDeskPageState();
}

class _MyDeskPageState extends State<MyDeskPage> {
  Map<String, String> deviceInfo = {};
  @override
  void initState() {
    super.initState();
    getDeviceName();
  }

  Future<void> getDeviceName() async {
    final info = await getDeviceInfo();
    setState(() {
      deviceInfo = info;
    });
    // debugPrint('Device: $deviceName');
  }
  @override
  Widget build(BuildContext context) {
    // debugPrint('Device build: $deviceName');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Desk'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              child: Image.network(placeholderProfilePic),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  deviceInfo['deviceName']?? 'Device Name',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: MediaQuery.of(context).platformBrightness == Brightness.dark ? primaryGreen : Colors.grey[900]
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    // TODO: Implement edit button functionality
                    debugPrint('Use my desk for a minimum of 5 times to unlock this feature');
                  },
                  child: const Icon(Icons.edit_outlined, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Share links, text and files to me via this code,\nor scan the QR.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    deviceInfo['deviceId'] ?? '',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 310,
                    height: 310,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: QrImageView(
                        data: '${deviceInfo['deviceId']}@${deviceInfo['deviceName']}',
                        size: 300,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}