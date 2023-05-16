import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class PushNotification extends ModelMVC {
  FirebaseMessaging firebase_msg = FirebaseMessaging.instance;

  void requestPermission() async {
    NotificationSettings settings = await firebase_msg.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
}
