import 'package:authentication/models/registration_form_provider.dart';
import 'package:authentication/views/first_screen.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:firebase_data/models/push_notification.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:user_management/models/profile_edit_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:service/models/service_request_form_provider.dart';

PushNotification pushNoti = PushNotification();

Future<void> _backgroundHandler(RemoteMessage message) async {
  final notification = message.notification;
  if (notification != null) {
    pushNoti.displayNotification(notification);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  pushNoti.init();
  FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider<RegistrationFormProvider>(
            create: (_) => RegistrationFormProvider()),
        ChangeNotifierProvider<ServiceRequestFormProvider>(
            create: (_) => ServiceRequestFormProvider()),
        ChangeNotifierProvider<ProfileEditProvider>(
            create: (_) => ProfileEditProvider()),
      ],
      child: const MaterialApp(
        home: FirstScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
