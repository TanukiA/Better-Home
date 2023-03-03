import 'package:better_home/src/view/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: const Color.fromRGBO(
            152, 161, 127, 1), // set the background color here
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
                style: btnStyle,
                child: const Text(
                  'A Customer',
                ),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
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
                  width: 160,
                  height: 160,
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
