import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Given phone number is +60182733322 When ', () async {
    // TODO: Implement test
  });
}
/*
  static bool validPhoneFormat(String phone) {
    if ((phone.startsWith('+60') &&
            (phone.length == 12 || phone.length == 13)) ||
        phone.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
*/

/*
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/user.dart';

void main() {
  group('validPhoneFormat', () {
    test('returns true for valid phone format', () {
      expect(User.validPhoneFormat('+601234567890'), true);
      expect(User.validPhoneFormat('+6012345678901'), true);
      expect(User.validPhoneFormat(''), true);
    });

    test('returns false for invalid phone format', () {
      expect(User.validPhoneFormat('0123456789'), false);
      expect(User.validPhoneFormat('+60123456789012'), false);
      expect(User.validPhoneFormat('hello'), false);
    });
  });
}
*/