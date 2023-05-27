import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:user_management/models/app_notification.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationController extends ControllerMVC {
  late final AppNotification noti;

  NotificationController() {
    noti = AppNotification();
  }

  Future<List<AppNotification>> retrieveNotification(
      String userType, BuildContext context) async {
    return await noti.retrieveNotification(userType, context);
  }

  DateTime formatToLocalDateTime(DateTime dateTime) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime timeZoneDateTime = tz.TZDateTime.from(dateTime, location);
    return timeZoneDateTime;
  }

  String formatToLocalDate(DateTime dateTime) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime timeZoneDate = tz.TZDateTime.from(dateTime, location);
    return DateFormat('dd/MM/yyyy').format(timeZoneDate);
  }

  String formatToLocalTime(DateTime dateTime) {
    tz.initializeTimeZones();
    tz.Location location = tz.getLocation('Asia/Kuala_Lumpur');
    tz.TZDateTime timeZoneTime = tz.TZDateTime.from(dateTime, location);
    return DateFormat('HH:mm').format(timeZoneTime);
  }

  void setRead(String serviceID, String userType, BuildContext context) {
    noti.changeReadStatus(serviceID, userType, context);
  }
}
