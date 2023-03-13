import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isSignedIn = false;
  bool get isSignedIn => isSignedIn;
}
