/*
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize(BuildContext context) async {
    // Request permission for iOS
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,

      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted permission");
      getFCMToken(context);

      // Get the FCM token for the device
      String? token = await _messaging.getToken();
      print("Firebase Messaging Token: $token");

      // Initialize local notifications
      const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

      await _notificationsPlugin.initialize(initializationSettings);

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print("Message received: ${message.notification?.title}");
        _showNotification(
          message.notification?.title ?? '',
          message.notification?.body ?? '',
        );
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);
    } else {
      print("User declined or has not granted permission");
    }
  }

  static Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
    print("Handling background message: ${message.notification?.title}");
  }

  static Future<void> _showNotification(String title, String body) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id', // Channel ID
      'Channel Name', // Channel name
      channelDescription: 'Description of your channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(0, title, body, notificationDetails);
  }

    static Future<void> getFCMToken(BuildContext context) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final _deviceName = "${androidInfo.manufacturer} ${androidInfo.model}";
        debugPrint(_deviceName);
        if (Platform.isIOS) {
      // iOS device info
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      final _deviceName = iosInfo.name; // Device name on iOS
    }

    // Retrieve the token
    String? token = await messaging.getToken();
    print('FCM Token: $token');
    debugPrint("Device name: $_deviceName");

    // Save or send this token to your backend

    /*
    try {
        final response = await api.post(
          '/firebase-token',
          (json) => json,
          data: {
            'token': token,
            'deviceName': _deviceName,
          }
        );

        if (response != null) {
          debugPrint('Token successfully sent to server');
          debugPrint('Server response: $response');
        } else {
          throw Exception('Failed to send token to server');
        }
      } catch (e) {
        debugPrint('Error sending token to server, $e');
      }
      */
}
}
*/
