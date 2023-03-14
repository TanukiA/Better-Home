import 'package:authentication/models/user.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

class LoginController extends ControllerMVC {
  /*
  factory LoginController() => _this ??= LoginController._();
  LoginController._();
  static LoginController? _this;
*/
  late User _user;

  LoginController() {
    _user = User.withIdAndPhone('', '');
  }

  User get user => _user;

  bool validPhoneFormat(String phone) {
    return _user.validPhoneFormat(phone);
  }
}
