import 'package:mvc_pattern/mvc_pattern.dart';

class UserController extends ControllerMVC {
  factory UserController() => _this ??= UserController._();
  UserController._();
  static UserController? _this;
}
