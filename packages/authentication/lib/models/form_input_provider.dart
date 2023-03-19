import 'package:authentication/models/technician.dart';
import 'package:flutter/material.dart';

class FormInputProvider with ChangeNotifier {
  Technician _formInput = Technician();

  Technician get formInput => _formInput;

  set formInput(Technician value) {
    _formInput = value;
    notifyListeners();
  }
}
