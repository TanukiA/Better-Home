import 'package:mvc_pattern/mvc_pattern.dart';

class LoginController extends ControllerMVC {
  factory LoginController() => _this ??= LoginController._();
  LoginController._();
  static LoginController? _this;
}
