import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/views/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:better_home/user.dart' as my_user;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginController extends Mock implements LoginController {}

class MockBuildContext extends Fake implements BuildContext {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockPhoneAuthCredential extends Mock implements PhoneAuthCredential {}

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockLoginController mockController;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockAuthProvider mockAuthProvider;
  final mockNavigatorObserver = MockNavigatorObserver();

  setUpAll(() {
    mockController = MockLoginController();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockAuthProvider = MockAuthProvider();
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockPhoneAuthCredential());
  });
  group('User Login', () {
    test('Validate phone number format (positive input)', () {
      expect(my_user.User.validPhoneFormat('+60182814772'), true);
    });

    test('Validate phone number format (negative input)', () {
      expect(my_user.User.validPhoneFormat('+60123456789012'), false);
    });

    testWidgets('Show error dialog for unregistered phone number',
        (WidgetTester tester) async {
      when(() => mockController.validPhoneFormat(any())).thenReturn(true);

      when(() => mockController.isAccountExists(any(), any()))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(userType: 'customer', controller: mockController),
        navigatorObservers: [mockNavigatorObserver],
      ));

      final phoneTextField = find.byType(TextFormField);

      await tester.enterText(phoneTextField, '0198488832');
      await tester.pumpAndSettle();

      final loginBtn = find.widgetWithText(ElevatedButton, 'Login').first;

      // Verify that loginBtn is enabled after phone number is entered
      expect(tester.widget<ElevatedButton>(loginBtn).enabled, isTrue);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      verify(() => mockController.showUnregisteredError(any())).called(1);
    });

    testWidgets('Show error dialog for unapproved phone number',
        (WidgetTester tester) async {
      when(() => mockController.validPhoneFormat(any())).thenReturn(true);

      when(() => mockController.isAccountExists(any(), any()))
          .thenAnswer((_) async => true);

      when(() => mockController.isApprovedAccount(any()))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(MaterialApp(
        home: LoginScreen(userType: 'techniain', controller: mockController),
        navigatorObservers: [mockNavigatorObserver],
      ));

      final phoneTextField = find.byType(TextFormField);

      await tester.enterText(phoneTextField, '0123451234');
      await tester.pumpAndSettle();

      final loginBtn = find.widgetWithText(ElevatedButton, 'Login').first;

      // Verify that loginBtn is enabled after phone number is entered
      expect(tester.widget<ElevatedButton>(loginBtn).enabled, isTrue);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      verify(() => mockController.showUnapprovedError(any())).called(1);
    });

    test('Send OTP for registered phone number', () async {
      const mockPhoneNumber = '+60123456789';
      const mockVerificationId = '1234';

      final mockPhoneAuthCredential = MockPhoneAuthCredential();
      when(() => mockPhoneAuthCredential.verificationId)
          .thenReturn(mockVerificationId);
      when(() => mockPhoneAuthCredential.smsCode).thenReturn('123456');

      when(() => mockFirebaseAuth.signInWithCredential(any()))
          .thenAnswer((_) async => mockUserCredential);

      when(() => mockFirebaseAuth.verifyPhoneNumber(
            phoneNumber: mockPhoneNumber,
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).thenAnswer((_) async {
        final codeSentCallback = _.positionalArguments[2] as Function;
        await codeSentCallback(mockVerificationId, null);
      });

      mockFirebaseAuth.verifyPhoneNumber(
        phoneNumber: mockPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) =>
            Future.value(),
        verificationFailed: (FirebaseAuthException error) => Future.value(),
        codeSent: (String verificationId, int? forceResendingToken) =>
            Future.value(),
        codeAutoRetrievalTimeout: (String verificationId) {},
      );

      verify(() => mockFirebaseAuth.verifyPhoneNumber(
            phoneNumber: mockPhoneNumber,
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).called(1);

      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('Resend OTP', () async {
      final mockFirebaseAuth = MockFirebaseAuth();
      const mockVerificationId = '1234';
      mockAuthProvider.setForceResendingToken = 123;

      when(() => mockFirebaseAuth.currentUser?.phoneNumber)
          .thenReturn('+60123456789');
      when(() => mockFirebaseAuth.verifyPhoneNumber(
            phoneNumber: any(named: 'phoneNumber'),
            forceResendingToken: any(named: 'forceResendingToken'),
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).thenAnswer((_) async {
        final codeSentCallback = _.positionalArguments[2] as Function;
        await codeSentCallback(mockVerificationId, 567);
      });

      final result = await mockAuthProvider.resendOTP();

      expect(result, true);
      verify(() => mockFirebaseAuth.verifyPhoneNumber(
            phoneNumber: '+60123456789',
            forceResendingToken: 123,
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).called(1);
      verify(() => mockFirebaseAuth.signInWithCredential(
            any(),
          )).called(1);
    });
  });
}
