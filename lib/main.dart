import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        backgroundColor:
            Color.fromRGBO(152, 161, 127, 1), // set the background color here
        body: Center(
          child: Text('Hello, world!'),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
