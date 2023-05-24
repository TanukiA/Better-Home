import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_data/models/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotification extends ModelMVC {
  final FirebaseMessaging _firebaseMsg = FirebaseMessaging.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? deviceToken;

  Future<void> init() async {
    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher');
    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    await _firebaseMsg.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Push notification received by device");
      final notification = message.notification;
      final data = message.data;
      print("The message data: $data");
      if (notification != null) {
        final title = notification.title ?? '';
        final body = notification.body ?? '';
        print("onMessage - Title: $title, Body: $body");

        displayNotification(data);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Push notification received by device");
      final notification = message.notification;
      final data = message.data;
      print("The message data: $data");
      if (notification != null) {
        final title = notification.title ?? '';
        final body = notification.body ?? '';
        print("onMessageOpenedApp - Title: $title, Body: $body");

        displayNotification(data);
      }
    });
  }

  void displayNotification(Map<String, dynamic> message) {
    // Create a custom notification using the notification data and data payload
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('betterHome_channel_id', 'betterHome',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'] as String,
        message['notification']['body'] as String,
        platformChannelSpecifics);
  }

  Future<void> obtainDeviceToken() async {
    await _firebaseMsg.requestPermission();

    deviceToken = await _firebaseMsg.getToken();
  }

  Future<void> saveDeviceToken(String userID) async {
    Database firestore = Database();
    firestore.storeDeviceToken(userID, deviceToken!);
  }

  void sendMessageNotification(
      String receiverId, String senderName, String messageText) async {
    final Uri uri = Uri.parse(
            'https://us-central1-better-home-a2dbf.cloudfunctions.net/sendMessageNotification')
        .replace(queryParameters: {
      'receiverId': receiverId,
      'senderName': senderName,
      'messageText': messageText,
    });

    try {
      final response = await http.post(uri);

      if (response.statusCode == 200) {
        print('Response code: ${response.statusCode}');
        print('Response body: ${response.body}');
        print('Response headers: ${response.headers}');
      }
    } catch (e) {
      throw PlatformException(
          code: 'send-notification-failed', message: e.toString());
    }
  }

  Future<void> sendServiceStatusNotification() async {
    final sendNotification = _functions.httpsCallable('serviceStatusChanged');

    try {
      await sendNotification.call();
      print('Push notification sent successfully');
    } catch (error) {
      print('Failed to send push notification: $error');
    }
  }
}
