import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/views/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:better_home/user.dart' as my_user;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class MockLoginController extends Mock implements LoginController {}

class MockBuildContext extends Fake implements BuildContext {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAuthCredential extends Mock implements AuthCredential {}

class MockPhoneAuthCredential extends Mock implements PhoneAuthCredential {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  late MockLoginController mockController;
  late MockAuthProvider mockAuthProvider;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockPhoneAuthCredential mockPhoneAuthCredential;
  final mockNavigatorObserver = MockNavigatorObserver();

  setUpAll(() {
    mockController = MockLoginController();
    mockAuthProvider = MockAuthProvider();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockPhoneAuthCredential = MockPhoneAuthCredential();
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(MockAuthCredential());
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
      // Arrange
      const mockPhoneNumber = '+60123456789';
      const mockSmsCode = '123456';
      final mockUser = MockUser(
        isAnonymous: false,
        uid: 'mock-uid',
        email: 'mock-email@example.com',
        displayName: 'Mock User',
      );

      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => Stream.fromIterable([null, mockUser]));

      when(() => mockAuthProvider.signInWithPhone(
            any(),
            mockPhoneNumber,
            any(),
            any(),
          )).thenAnswer((_) async {
        await mockFirebaseAuth.signInWithCredential(mockPhoneAuthCredential);
      });

      when(() => mockFirebaseAuth.verifyPhoneNumber(
            phoneNumber: any(named: 'phoneNumber'),
            verificationCompleted: any(named: "verificationCompleted"),
            verificationFailed: any(named: "verificationFailed"),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).thenAnswer((Invocation invocation) async {});

      when(() => mockPhoneAuthCredential.smsCode).thenReturn(mockSmsCode);
      when(() => mockFirebaseAuth.signInWithCredential(mockPhoneAuthCredential))
          .thenAnswer((_) async => mockUserCredential);

      // Act
      final context = MockBuildContext();
      mockAuthProvider.signInWithPhone(
        context,
        mockPhoneNumber,
        'UserType',
        'Purpose',
      );
      await mockFirebaseAuth
          .authStateChanges()
          .firstWhere((user) => user != null);

      // Assert
      verify(() => mockFirebaseAuth.signInWithCredential(any())).called(1);
    });

    test('Resend OTP', () async {
      when(() => mockAuthProvider.resendOTP('+60123456789'))
          .thenAnswer((_) async => true);

      when(() => mockFirebaseAuth.verifyPhoneNumber(
            phoneNumber: any(named: 'phoneNumber'),
            forceResendingToken: any(named: 'forceResendingToken'),
            verificationCompleted: any(named: 'verificationCompleted'),
            verificationFailed: any(named: 'verificationFailed'),
            codeSent: any(named: 'codeSent'),
            codeAutoRetrievalTimeout: any(named: 'codeAutoRetrievalTimeout'),
          )).thenAnswer((Invocation invocation) async {});

      final result = await mockAuthProvider.resendOTP('+60123456789');

      expect(result, true);
    });
  });
}
