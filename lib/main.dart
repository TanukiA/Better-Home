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

Future<void> backgroundHandler(RemoteMessage message) async {
  print(" --- background message received ---");
  print(message.notification!.title);
  print(message.notification!.body);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotification().init();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
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
