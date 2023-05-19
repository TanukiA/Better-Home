import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:cloud_functions/cloud_functions.dart';

class PushNotification extends ModelMVC {
  final FirebaseMessaging _firebase_msg = FirebaseMessaging.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  //late FlutterLocalNotificationPlugin notificationPlugin = FlutterLocalNotificationPlugin;
  String? mtoken = "";

  void requestPermission() async {
    await _firebase_msg.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  void sendPushNotification(String connectionID, String messageID) async {
    final sendNotification =
        _functions.httpsCallable('sendMessageNotification');

    try {
      await sendNotification
          .call({'connectionId': connectionID, 'messageId': messageID});
      print('Push notification sent successfully');
    } catch (error) {
      print('Failed to send push notification: $error');
    }
  }
/*
  void getToken() async {
    await _firebase_msg.getToken().then((token) {
      setState(() {
        mtoken = token;
        print("Token is $mtoken");
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await _firebaseFirestore.collection("UserTokens").doc("User2").set({
      'token': token,
    });
  }

  // get token in User class
  void sendPushMessage(String token, String body, String title) async {
    try {
      await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization': ''
          });
    } catch (e) {}
  }
  */
}
