import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/views/customer_home_screen.dart';
import 'package:authentication/views/login_screen.dart';
import 'package:authentication/views/technician_home_screen.dart';
import 'package:firebase_data/models/push_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:service/controllers/technician_controller.dart';
import 'package:service/controllers/customer_controller.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ap = Provider.of<AuthProvider>(context, listen: false);
    Size size = MediaQuery.of(context).size;
    /*
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String id = await ap.getUserIDFromSP("session_data");
      PushNotification pushNoti = PushNotification();
      await pushNoti.obtainDeviceToken();
      pushNoti.saveDeviceToken(id);
    });
    */
    final ButtonStyle btnStyle = ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontSize: 20,
          fontFamily: 'Roboto',
        ),
        backgroundColor: const Color.fromRGBO(238, 231, 194, 1),
        foregroundColor: Colors.black,
        fixedSize: const Size(300, 67));

    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromRGBO(152, 161, 127, 1),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 96),
              const Text(
                'WHO ARE YOU?',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () async {
                  ap.isCustomerSignedIn == true
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CustomerHomeScreen(
                                    loginCon: LoginController("customer"),
                                    cusCon: CustomerController(),
                                  )))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                              userType: 'customer',
                              controller: LoginController("customer"),
                            ),
                          ));
                },
                style: btnStyle,
                child: const Text(
                  'A Customer',
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () async {
                  ap.isTechnicianSignedIn == true
                      ? Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => TechnicianHomeScreen(
                                    loginCon: LoginController("technician"),
                                    techCon: TechnicianController(),
                                  )))
                      : Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(
                              userType: 'technician',
                              controller: LoginController("technician"),
                            ),
                          ));
                },
                style: btnStyle,
                child: const Text(
                  'A Technician',
                ),
              ),
              const SizedBox(height: 100),
              Align(
                alignment: Alignment.bottomCenter,
                child: SvgPicture.asset(
                  'assets/people_img.svg',
                  width: size.width * 0.2,
                  height: size.height * 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
