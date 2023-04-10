import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/views/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_db/models/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_home/user.dart';
import 'package:better_home/customer.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mockito/mockito.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('Customer Login', () {
    User _user;

    setUpAll(() {});

    test('Validate phone number format (positive input)', () {
      expect(User.validPhoneFormat('+60182814772'), true);
    });

    test('Validate phone number format (negative input)', () {
      expect(User.validPhoneFormat('+60123456789012'), false);
    });
    /*
    testWidgets(
        'Error dialog is shown when user logs in with unregistered phone number',
        (WidgetTester tester) async {
      final loginController = LoginController("customer");
      final mockContext = MockBuildContext();
      await tester.pumpWidget(
          LoginScreen(userType: "customer", controller: loginController));

      final phoneTextField = find.byType(TextFormField);

      // Enter an unregistered phone number
      await tester.enterText(phoneTextField, '0198488832');

      when(loginController.isAccountExists("", ""))
          .thenReturn(Future.value(false));

      final loginBtn = find.widgetWithText(ElevatedButton, 'Login').first;
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Verify that the showUnregisteredError method is called
      verify(loginController.showUnregisteredError(mockContext)).called(1);

      // Verify that the error dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Unregistered phone number'), findsOneWidget);
      expect(
          find.text('Please login with a registered number.'), findsOneWidget);
    });
    */

    testWidgets(
        'Error dialog is shown when user logs in with unregistered phone number',
        (WidgetTester tester) async {
      var mockController = MockLoginController();
      var mockUser = MockUser();
      final mockContext = MockBuildContext();

      //when(MockUser.validPhoneFormat("")).thenReturn(false);

      var loginScreen =
          LoginScreen(userType: "customer", controller: mockController);
      await tester.pumpWidget(loginScreen);
      /*
      final phoneTextField = find.byType(TextFormField);

      await tester.enterText(phoneTextField, '0198488832');

      when(mockController.isAccountExists("", ""))
          .thenAnswer((_) => Future.value(false));

      final loginBtn = find.widgetWithText(ElevatedButton, 'Login').first;
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      // Verify that the showUnregisteredError method is called
      verify(mockController.showUnregisteredError(mockContext)).called(1);

      // Verify that the error dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Unregistered phone number'), findsOneWidget);
      expect(
          find.text('Please login with a registered number.'), findsOneWidget);
          */
    });
/*
    test('Send OTP to the registered phone number', () {
      final context = MockBuildContext();
      final authProvider = MockAuthProvider();

      _user = Customer();
      _user.sendPhoneNumber(context, '+60123456789', 'customer', 'login');

      verify(authProvider.signInWithPhone(
              context, '+60123456789', 'customer', 'login'))
          .called(1);
    });
    */
  });
}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockFirestore extends Mock implements FirebaseFirestore {}

class MockLoginController extends Mock implements LoginController {}

class MockUser extends Mock implements User {}

class MockDatabase extends Mock implements Database {
  final MockFirestore _mockFirestore = MockFirestore();

  @override
  Future<bool> checkAccountExistence(
      String phoneNumber, String collectionName) async {
    final querySnapshot = await _mockFirestore
        .collection(collectionName)
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}
