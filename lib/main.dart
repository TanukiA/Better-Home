import 'package:authentication/models/form_input_provider.dart';
import 'package:authentication/views/first_screen.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:service/models/serviceRequestForm_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        ChangeNotifierProvider<FormInputProvider>(
            create: (_) => FormInputProvider()),
        ChangeNotifierProvider<ServiceRequestFormProvider>(
            create: (_) => ServiceRequestFormProvider()),
      ],
      child: const MaterialApp(
        home: FirstScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
