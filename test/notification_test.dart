import 'package:firebase_data/models/push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockNotification extends Mock implements RemoteNotification {}

void main() {
  late MockHttpClient httpClient;
  late MockPushNotification mockPushNotification;
  late MockNotification mockNotification;
  late MockFlutterLocalNotificationsPlugin mockLocalNotificationsPlugin;

  setUpAll(() {
    httpClient = MockHttpClient();
    mockNotification = MockNotification();
    mockLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockPushNotification =
        MockPushNotification(httpClient, mockLocalNotificationsPlugin);
  });
  group('Notifications', () {
    test('Send push notification', () async {
      const receiverId = 'ABC123';
      const senderName = 'Anthony Fong An Tian';
      const messageText = 'I will be there in around 15 min';

      final expectedUri = Uri.parse(
        'https://us-central1-better-home-a2dbf.cloudfunctions.net/sendMessageNotification',
      ).replace(queryParameters: {
        'receiverId': receiverId,
        'senderName': senderName,
        'messageText': messageText,
      });

      when(() => httpClient.post(expectedUri))
          .thenAnswer((_) async => http.Response('Success', 200));

      await mockPushNotification.sendMessageNotification(
          receiverId, senderName, messageText);

      verify(() => httpClient.post(expectedUri)).called(1);
    });

    test('Display push notification', () async {
      const expectedTitle = 'Anthony Fong An Tian sends a new message:';
      const expectedBody = 'I will be there in around 15 min';

      when(() => mockNotification.title).thenReturn(expectedTitle);
      when(() => mockNotification.body).thenReturn(expectedBody);
      when(() => mockLocalNotificationsPlugin.show(
            0,
            expectedTitle,
            expectedBody,
            any(),
          )).thenAnswer((_) async => Future<void>);

      mockPushNotification.displayNotification(mockNotification);

      verify(() => mockLocalNotificationsPlugin.show(
            0,
            expectedTitle,
            expectedBody,
            any(),
          )).called(1);
    });
  });
}

class MockPushNotification extends Mock implements PushNotification {
  final MockHttpClient _mockHttpClient;
  final MockFlutterLocalNotificationsPlugin _mockNotificationsPlugin;

  MockPushNotification(this._mockHttpClient, this._mockNotificationsPlugin);

  @override
  Future<void> sendMessageNotification(
      String receiverId, String senderName, String messageText) async {
    final Uri uri = Uri.parse(
            'https://us-central1-better-home-a2dbf.cloudfunctions.net/sendMessageNotification')
        .replace(queryParameters: {
      'receiverId': receiverId,
      'senderName': senderName,
      'messageText': messageText,
    });

    try {
      await _mockHttpClient.post(uri);
    } catch (e) {
      throw PlatformException(
          code: 'send-notification-failed', message: e.toString());
    }
  }

  @override
  void displayNotification(RemoteNotification notification) {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('betterHome_channel_id', 'betterHome',
            importance: Importance.max, priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    _mockNotificationsPlugin.show(
        0, notification.title, notification.body, platformChannelSpecifics);
  }
}
