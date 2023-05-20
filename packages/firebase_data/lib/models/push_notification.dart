import 'package:firebase_data/models/database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

class PushNotification extends ModelMVC {
  final FirebaseMessaging _firebaseMsg = FirebaseMessaging.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  String? deviceToken;

  Future<void> obtainDeviceToken() async {
    await _firebaseMsg.requestPermission();

    deviceToken = await _firebaseMsg.getToken();
  }

  Future<void> saveDeviceToken(String userID) async {
    Database firestore = Database();
    firestore.storeDeviceToken(userID, deviceToken!);
  }

  void sendPushNotification(
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
        print('Push notification sent successfully');
      } else {
        print("Response code: ${response.statusCode}");
      }
    } catch (error) {
      print('Failed to send push notification: $error');
    }
  }
}
