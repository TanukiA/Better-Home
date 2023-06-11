import 'package:firebase_data/models/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotification extends ModelMVC {
  final FirebaseMessaging _firebaseMsg = FirebaseMessaging.instance;
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

    _firebaseMsg.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;

      if (notification != null) {
        displayNotification(notification);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification != null) {
        displayNotification(notification);
      }
    });
  }

  void displayNotification(RemoteNotification notification) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('betterHome_channel_id', 'betterHome',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    flutterLocalNotificationsPlugin.show(
        0, notification.title, notification.body, platformChannelSpecifics);
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
      await http.post(uri);
    } catch (e) {
      throw PlatformException(
          code: 'send-notification-failed', message: e.toString());
    }
  }

  Future<void> sendServiceConfirmedNotification(
      String customerId, String serviceName, String technicianName) async {
    final Uri uri = Uri.parse(
            'https://us-central1-better-home-a2dbf.cloudfunctions.net/serviceConfirmedNotification')
        .replace(queryParameters: {
      'customerId': customerId,
      'serviceName': serviceName,
      'technicianName': technicianName,
    });

    try {
      await http.post(uri);
    } catch (e) {
      throw PlatformException(
          code: 'send-notification-failed', message: e.toString());
    }
  }

  Future<void> sendServicStatusChangedNotification(
      String receiverId, String newStatus, String serviceName) async {
    final Uri uri = Uri.parse(
            'https://us-central1-better-home-a2dbf.cloudfunctions.net/serviceStatusChangedNotification')
        .replace(queryParameters: {
      'receiverId': receiverId,
      'newStatus': newStatus,
      'serviceName': serviceName,
    });

    try {
      await http.post(uri);
    } catch (e) {
      throw PlatformException(
          code: 'send-notification-failed', message: e.toString());
    }
  }

  Future<void> sendServiceAssignedNotification(
      String technicianId, String serviceName) async {
    final Uri uri = Uri.parse(
            'https://us-central1-better-home-a2dbf.cloudfunctions.net/serviceAssignedNotification')
        .replace(queryParameters: {
      'technicianId': technicianId,
      'serviceName': serviceName,
    });

    try {
      await http.post(uri);
    } catch (e) {
      throw PlatformException(
          code: 'send-notification-failed', message: e.toString());
    }
  }
}
