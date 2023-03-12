import 'package:mvc_pattern/mvc_pattern.dart';

class User extends ModelMVC {
  final String id;
  final String phone;
  final String name;
  final String email;
  String _errorText = "";

  User(
      {required this.id,
      required this.phone,
      required this.name,
      required this.email});

  String get errorText => _errorText;

  String validPhoneNumber(String phone) {
    if (phone.startsWith('+60')) {
      _errorText = "";
      notifyListeners();
      return _errorText;
    } else {
      _errorText = 'Invalid phone number';
      notifyListeners();
      return _errorText;
    }
  }
}
