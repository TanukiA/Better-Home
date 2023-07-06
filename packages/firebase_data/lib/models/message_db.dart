import 'dart:async';
import 'package:firebase_data/models/push_notification.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:user_management/models/message.dart';

class MessageDB extends ChangeNotifier {
  final FirebaseDatabase _realtimeDB = FirebaseDatabase.instance;

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

    // Check if the connection with matched technicianID and customerID already exists
    await messagesRef.once().then((DatabaseEvent snapshot) async {
      Map<dynamic, dynamic>? values =
          snapshot.snapshot.value as Map<dynamic, dynamic>?;
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

    // if connection doesn't exist yet
    // Generate a new unique connectionID and set new child with it
    if (connectionID == null) {
      connectionID = messagesRef.push().key;
      await messagesRef.child(connectionID!).set({
        'technicianID': technicianID,
        'customerID': customerID,
      });
    }

    String? messageID = messagesRef.child(connectionID!).push().key;

    // Store new message
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

      // Send push notification after storing the message
      PushNotification pushNoti = PushNotification();
      pushNoti.sendMessageNotification(receiverID, senderName, messageText);
    } catch (e) {
      throw PlatformException(
          code: 'add-message-failed', message: e.toString());
    }
  }

  Future<List<List<Message>>> retrieveAllUserMessages(
      String currentID, String userType) async {
    DatabaseReference messagesRef = _realtimeDB.ref().child('messages');

    List<List<Message>> allUserMessages = [];

    await messagesRef.once().then((DatabaseEvent snapshot) async {
      Map<dynamic, dynamic>? values =
          snapshot.snapshot.value as Map<dynamic, dynamic>?;
      if (values != null) {
        for (var key in values.keys) {
          var item = values[key];
          if (userType == 'customer') {
            if (item['customerID'] == currentID) {
              allUserMessages
                  .add(await getMessagesFromConnection(key, messagesRef));
            }
          } else if (userType == 'technician') {
            if (item['technicianID'] == currentID) {
              allUserMessages
                  .add(await getMessagesFromConnection(key, messagesRef));
            }
          }
        }
      }
    });

    return allUserMessages;
  }

  Future<List<Message>> retrieveSingleUserMessages(
      String customerID, String technicianID) async {
    DatabaseReference messagesRef = _realtimeDB.ref().child('messages');
    String? connectionID;

    // Check if there is connection between technician and customer
    await messagesRef.once().then((DatabaseEvent snapshot) async {
      Map<dynamic, dynamic>? values =
          snapshot.snapshot.value as Map<dynamic, dynamic>?;
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
      return [];
    }

    List<Message> messages =
        await getMessagesFromConnection(connectionID!, messagesRef);
    return messages;
  }

  Future<List<Message>> getMessagesFromConnection(
      String connectionID, DatabaseReference messagesRef) async {
    Query collectionRef =
        messagesRef.child(connectionID).orderByChild('dateTime');
    DatabaseEvent collectionSnapshot = await collectionRef.once();
    Map<dynamic, dynamic>? collectionValues =
        collectionSnapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (collectionValues == null) {
      return [];
    }

    List<Message> messages = [];
    collectionValues.forEach((key, value) {
      if (key != 'customerID' && key != 'technicianID') {
        DateTime dateTime = DateTime.parse(value['dateTime']);
        Message message = Message(
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

  void updateReadStatus(String connectionID, String currentID) async {
    DatabaseReference messagesRef = _realtimeDB.ref().child('messages');

    messagesRef.child(connectionID).once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> messagesData =
            snapshot.value as Map<dynamic, dynamic>;

        messagesData.forEach((key, value) {
          if (key != 'customerID' && key != 'technicianID') {
            if (value['receiverId'] == currentID) {
              messagesRef.child(connectionID).child(key).update({
                'readStatus': true,
              });
            }
          }
        });
      }
    });
  }
}
