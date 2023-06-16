// ignore_for_file: subtype_of_sealed_class

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_data/models/message_db.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:user_management/models/message.dart';

class MockDatabaseReference extends Mock implements DatabaseReference {}

class MockDataSnapshot extends Mock implements DataSnapshot {}

class MockDatabaseEvent extends Mock implements DatabaseEvent {}

class MockFirebaseDatabase extends Mock implements FirebaseDatabase {}

void main() {
  late MockMessageDB mockMessageDB;
  late MockFirebaseDatabase mockFirebaseDatabase;
  late MockDataSnapshot mockCollectionSnapshot;
  late MockDatabaseReference mockDatabaseRef;

  setUpAll(() {
    mockFirebaseDatabase = MockFirebaseDatabase();
    mockDatabaseRef = MockDatabaseReference();
    mockCollectionSnapshot = MockDataSnapshot();
    mockMessageDB = MockMessageDB(mockFirebaseDatabase, mockCollectionSnapshot);
  });

  group('Messaging', () {
    test('Retrieve message data from a messaging connection', () async {
      const connectionID = '12345';

      final collectionValues = {
        'message1': {
          'dateTime': '2022-01-01T00:00:00Z',
          'senderId': 'sender1',
          'senderName': 'Sender 1',
          'receiverId': 'receiver1',
          'receiverName': 'Receiver 1',
          'messageText': 'Test message 1',
          'readStatus': false,
        },
        'message2': {
          'dateTime': '2022-01-02T00:00:00Z',
          'senderId': 'sender2',
          'senderName': 'Sender 2',
          'receiverId': 'receiver2',
          'receiverName': 'Receiver 2',
          'messageText': 'Test message 2',
          'readStatus': true,
        },
      };

      when(() => mockDatabaseRef.child(connectionID))
          .thenReturn(mockDatabaseRef);
      when(() => mockDatabaseRef.orderByChild('dateTime'))
          .thenReturn(mockDatabaseRef);
      when(() => mockDatabaseRef.once())
          .thenAnswer((_) async => MockDatabaseEvent());
      when(() => mockCollectionSnapshot.value).thenReturn(collectionValues);
      when(() => mockCollectionSnapshot.key).thenReturn('test_key');

      final messages = await mockMessageDB.getMessagesFromConnection(
          connectionID, mockDatabaseRef);

      expect(messages.length, equals(2));
    });

    test(
        'Retrieve message data from a messaging connection (message not found)',
        () async {
      const connectionID = '67890';

      when(() => mockDatabaseRef.child(connectionID))
          .thenReturn(mockDatabaseRef);
      when(() => mockDatabaseRef.orderByChild(any()))
          .thenReturn(mockDatabaseRef);
      when(() => mockDatabaseRef.once())
          .thenAnswer((_) async => MockDatabaseEvent());
      when(() => mockCollectionSnapshot.value).thenReturn(null);
      when(() => mockCollectionSnapshot.key).thenReturn(null);

      final messages = await mockMessageDB.getMessagesFromConnection(
          connectionID, mockDatabaseRef);

      expect(messages.length, equals(0));
    });

    test('Send message to a user who has not messaged previously', () async {
      const customerID = 'test_customer_id';
      const technicianID = 'test_technician_id';
      const senderID = 'test_sender_id';
      const receiverID = 'test_receiver_id';
      const senderName = 'Test Sender';
      const receiverName = 'Test Receiver';
      const messageText = 'Test message';
      /*
      when(() => mockFirebaseDatabase.ref().child('messages'))
          .thenReturn(mockDatabaseRef);*/
      when(() => mockDatabaseRef.child('connection_id'))
          .thenReturn(mockDatabaseRef);
      when(() => mockFirebaseDatabase.ref()).thenReturn(mockDatabaseRef);
      when(() => mockDatabaseRef.once())
          .thenAnswer((_) async => MockDatabaseEvent());

      when(() => mockDatabaseRef.child('connection_id'))
          .thenReturn(mockDatabaseRef);
      when(() => mockDatabaseRef.push()).thenReturn(mockDatabaseRef);
      when(() => mockDatabaseRef.push().key).thenReturn('connection_id');
      when(() => mockDatabaseRef.child('connection_id').set(any()))
          .thenAnswer((_) async => Future<void>.value());
      when(() => mockDatabaseRef
          .child('connection_id')
          .child('message_id')
          .set(any())).thenAnswer((_) async => Future<void>.value());

      await mockMessageDB.storeNewMessage(
        customerID,
        technicianID,
        senderID,
        receiverID,
        senderName,
        receiverName,
        messageText,
      );

      verify(() => mockDatabaseRef.once()).called(1);
      verify(() => mockDatabaseRef.push()).called(1);
      verify(() => mockDatabaseRef
          .child('connection_id')
          .child('message_id')
          .set(any())).called(1);
    });
  });
}

class MockMessageDB extends Mock implements MessageDB {
  final MockFirebaseDatabase _realtimeDB;
  final MockDataSnapshot _dataSnapshot;
  //final MockDatabaseReference _mockDatabaseRef;

  MockMessageDB(this._realtimeDB, this._dataSnapshot);

  @override
  Future<List<MockMessage>> getMessagesFromConnection(
      String connectionID, DatabaseReference messagesRef) async {
    Query collectionRef =
        messagesRef.child(connectionID).orderByChild('dateTime');
    DatabaseEvent collectionSnapshot = await collectionRef.once();
    Map<dynamic, dynamic>? collectionValues =
        _dataSnapshot.value as Map<dynamic, dynamic>?;

    if (collectionValues == null) {
      return [];
    }

    List<MockMessage> messages = [];
    collectionValues.forEach((key, value) {
      if (key != 'customerID' && key != 'technicianID') {
        DateTime dateTime = DateTime.parse(value['dateTime']);
        MockMessage message = MockMessage(
          connectionID: connectionID,
          messageID: key,
          dateTime: dateTime,
          senderID: value['senderId'],
          senderName: value['senderName'],
          receiverID: value['receiverId'],
          receiverName: value['receiverName'],
          messageText: value['messageText'],
          readStatus: value['readStatus'],
        );
        messages.add(message);
      }
    });

    messages.sort((a, b) => a.dateTime!.compareTo(b.dateTime!));

    return messages;
  }

  @override
  Future<void> storeNewMessage(
      String customerID,
      String technicianID,
      String senderID,
      String receiverID,
      String senderName,
      String receiverName,
      String messageText) async {
    DatabaseReference messagesRef = _realtimeDB.ref().child('messages');
    String? connectionID;

    await messagesRef.once().then((DatabaseEvent snapshot) async {
      Map<dynamic, dynamic>? values =
          _dataSnapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        values.forEach((key, item) {
          if (item['technicianID'] == technicianID &&
              item['customerID'] == customerID) {
            connectionID = key;
            return;
          }
        });
      }
    });

    if (connectionID == null) {
      connectionID = messagesRef.push().key;
      await messagesRef.child(connectionID!).set({
        'technicianID': technicianID,
        'customerID': customerID,
      });
    }

    String? messageID = messagesRef.child(connectionID!).push().key;

    try {
      await messagesRef.child(connectionID!).child(messageID!).set(Message(
            dateTime: DateTime.now(),
            senderID: senderID,
            receiverID: receiverID,
            senderName: senderName,
            receiverName: receiverName,
            messageText: messageText,
            readStatus: false,
          ).toJson());
    } catch (e) {
      throw PlatformException(
          code: 'add-message-failed', message: e.toString());
    }
  }
}

class MockMessage extends Mock implements Message {
  @override
  late MessageDB msgDB;
  @override
  String? connectionID;
  @override
  String? messageID;
  @override
  DateTime? dateTime;
  @override
  String? senderID;
  @override
  String? receiverID;
  @override
  String? senderName;
  @override
  String? receiverName;
  @override
  String? messageText;
  @override
  bool? readStatus;

  MockMessage({
    this.connectionID,
    this.messageID,
    this.dateTime,
    this.senderID,
    this.receiverID,
    this.senderName,
    this.receiverName,
    this.messageText,
    this.readStatus,
  });

  @override
  Map<String, dynamic> toJson() => {
        'connectionId': connectionID,
        'messageId': messageID,
        'dateTime': dateTime?.toIso8601String(),
        'senderId': senderID,
        'receiverId': receiverID,
        'senderName': senderName,
        'receiverName': receiverName,
        'messageText': messageText,
        'readStatus': readStatus,
      };
}
