import 'package:authentication/models/auth_provider.dart';
import 'package:firebase_data/models/database.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';

class AppNotification extends ModelMVC {
  String? serviceID;
  DateTime? dateTime;
  String? notiMessage;
  bool? readStatus;

  AppNotification({
    this.serviceID,
    this.dateTime,
    this.notiMessage,
    this.readStatus,
  });

  Map<String, dynamic> toJson() => {
        'serviceID': serviceID,
        'dateTime': dateTime?.toIso8601String(),
        'notiMessage': notiMessage,
        'readStatus': readStatus,
      };

  Future<void> addNewNotification(String userType, String serviceID,
      String notiMessage, String receiverID) async {
    final collectionName = userType == 'customer' ? 'customers' : 'technicians';

    final notification = AppNotification(
      serviceID: serviceID,
      dateTime: DateTime.now(),
      notiMessage: notiMessage,
      readStatus: false,
    );

    Database.storeNotification(notification, collectionName, receiverID);
  }

  Future<List<AppNotification>> retrieveNotification(
      String userType, BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String currentID = await ap.getUserIDFromSP("session_data");
    final collectionName = userType == 'customer' ? 'customers' : 'technicians';
    final notifications =
        await Database.readNotification(collectionName, currentID);
    return notifications;
  }

  Future<void> changeReadStatus(
      String serviceID, String userType, BuildContext context) async {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    String currentID = await ap.getUserIDFromSP("session_data");
    Database firestore = Database();
    firestore.updateReadStatus(serviceID, currentID, userType);
  }
}
