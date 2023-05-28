import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/views/active_service_detail_screen.dart';
import 'package:service/views/customer_past_service_detail_screen.dart';
import 'package:service/views/technician_past_service_detail_screen.dart';
import 'package:service/views/work_schedules_detail_screen.dart';
import 'package:user_management/controllers/messaging_controller.dart';
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

  Future<void> openRelevantScreen(
      String serviceID, String userType, BuildContext context) async {
    final serviceData = await noti.retrieveServiceData(serviceID);
    if (userType == "customer") {
      if (noti.serviceStatus == "Assigning" ||
          noti.serviceStatus == "Confirmed" ||
          noti.serviceStatus == "In Progress") {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActiveServiceDetailScreen(
                serviceDoc: serviceData,
                msgCon: MessagingController(),
                serviceCon: ServiceController(),
              ),
            ),
          );
        }
      } else if (noti.serviceStatus == "Completed" ||
          noti.serviceStatus == "Rated" ||
          noti.serviceStatus == "Cancelled" ||
          noti.serviceStatus == "Refunded") {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CustomerPastServiceDetailScreen(
                serviceDoc: serviceData,
                controller: ServiceController(),
              ),
            ),
          );
        }
      }
    } else {
      if (noti.serviceStatus == "Assigning" ||
          noti.serviceStatus == "Confirmed" ||
          noti.serviceStatus == "In Progress") {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkSchedulesDetailScreen(
                serviceDoc: serviceData,
                msgCon: MessagingController(),
                serviceCon: ServiceController(),
              ),
            ),
          );
        }
      } else if (noti.serviceStatus == "Completed" ||
          noti.serviceStatus == "Rated" ||
          noti.serviceStatus == "Cancelled" ||
          noti.serviceStatus == "Refunded") {
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TechnicianPastServiceDetailScreen(
                serviceDoc: serviceData,
                controller: ServiceController(),
              ),
            ),
          );
        }
      }
    }
  }

  void setRead(String serviceID, String userType, BuildContext context) {
    noti.changeReadStatus(serviceID, userType, context);
  }
}
