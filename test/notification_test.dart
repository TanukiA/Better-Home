// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_data/models/push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:user_management/controllers/notification_controller.dart';
import 'package:user_management/models/app_notification.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockNotification extends Mock implements RemoteNotification {}

class MockBuildContext extends Mock implements BuildContext {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockHttpClient httpClient;
  late MockPushNotification mockPushNotification;
  late MockNotification mockNotification;
  late MockFlutterLocalNotificationsPlugin mockLocalNotificationsPlugin;
  late MockBuildContext mockContext;
  late MockQueryDocumentSnapshot mockQueryDocumentSnapshot;

  setUpAll(() {
    httpClient = MockHttpClient();
    mockNotification = MockNotification();
    mockLocalNotificationsPlugin = MockFlutterLocalNotificationsPlugin();
    mockPushNotification =
        MockPushNotification(httpClient, mockLocalNotificationsPlugin);
    mockContext = MockBuildContext();
    mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

    registerFallbackValue(MockBuildContext());
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

    test('Create app notification', () async {
      const userType = 'customer';
      const serviceID = '12345';
      const notiMessage = 'Plumbing - Toilet Repair / Install is completed';
      const receiverID = 'ABC123';

      final mockAppNotification = MockAppNotification();
      mockAppNotification.serviceID = serviceID;
      mockAppNotification.dateTime = DateTime.now();
      mockAppNotification.notiMessage = notiMessage;
      mockAppNotification.readStatus = false;

      await mockAppNotification.addNewNotification(
        userType,
        serviceID,
        notiMessage,
        receiverID,
      );

      expect(mockAppNotification.serviceID, equals(serviceID));
      expect(mockAppNotification.dateTime, isA<DateTime>());
      expect(mockAppNotification.notiMessage, equals(notiMessage));
      expect(mockAppNotification.readStatus, isFalse);
    });

    test('Navigate to the screen relevant to app notification', () async {
      const userType = 'technician';
      const serviceID = '12345';
      const serviceStatus = 'Completed';

      bool correctCall = false;
      void call() {
        correctCall = true;
      }

      final mockAppNotification = MockAppNotification();
      final notificationController = MockNotificationController(
          mockAppNotification, call(), serviceStatus);

      when(() => mockAppNotification.retrieveServiceData(serviceID))
          .thenAnswer((_) async => mockQueryDocumentSnapshot);

      await notificationController.openRelevantScreen(
          serviceID, userType, mockContext);

      verify(() => mockAppNotification.retrieveServiceData(serviceID))
          .called(1);
      expect(correctCall, true);
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

class MockAppNotification extends Mock implements AppNotification {
  @override
  String? serviceID;
  @override
  DateTime? dateTime;
  @override
  String? notiMessage;
  @override
  bool? readStatus;
  @override
  String? serviceStatus;

  MockAppNotification({
    this.serviceID,
    this.dateTime,
    this.notiMessage,
    this.readStatus,
  });

  @override
  Map<String, dynamic> toJson() => {
        'serviceID': serviceID,
        'dateTime': dateTime?.toIso8601String(),
        'notiMessage': notiMessage,
        'readStatus': readStatus,
      };

  @override
  Future<void> addNewNotification(String userType, String serviceID,
      String notiMessage, String receiverID) async {
    final collectionName = userType == 'customer' ? 'customers' : 'technicians';

    final notification = MockAppNotification(
      serviceID: serviceID,
      dateTime: DateTime.now(),
      notiMessage: notiMessage,
      readStatus: false,
    );
  }
}

class MockNotificationController extends Mock
    implements NotificationController {
  @override
  final MockAppNotification noti;
  void correctCall;
  String serviceStatus;

  MockNotificationController(this.noti, this.correctCall, this.serviceStatus);

  @override
  Future<void> openRelevantScreen(
      String serviceID, String userType, BuildContext context) async {
    final serviceData = await noti.retrieveServiceData(serviceID);
    if (userType == "customer") {
      if (serviceStatus == "Assigning" ||
          serviceStatus == "Confirmed" ||
          serviceStatus == "In Progress") {
      } else if (serviceStatus == "Completed" ||
          serviceStatus == "Rated" ||
          serviceStatus == "Cancelled" ||
          serviceStatus == "Refunded") {}
    } else {
      if (serviceStatus == "Assigning" ||
          serviceStatus == "Confirmed" ||
          serviceStatus == "In Progress") {
      } else if (serviceStatus == "Completed" ||
          serviceStatus == "Rated" ||
          serviceStatus == "Cancelled" ||
          serviceStatus == "Refunded") {
        correctCall;
      }
    }
  }
}
