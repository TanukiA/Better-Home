import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:authentication/views/login_screen.dart';
import 'package:better_home/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:better_home/user.dart' as my_user;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockLoginController extends Mock implements LoginController {}

class MockBuildContext extends Fake implements BuildContext {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockUserCredential extends Mock implements UserCredential {}

class MockAuthCredential extends Mock implements AuthCredential {}

class MockPhoneAuthCredential extends Mock implements PhoneAuthCredential {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late MockLoginController mockController;
  late MockAuthProvider mockAuthProvider;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockPhoneAuthCredential mockPhoneAuthCredential;
  late MockSharedPreferences mockSharedPreferences;
  late MockBuildContext context;

  final mockNavigatorObserver = MockNavigatorObserver();

  setUp(() {
    mockController = MockLoginController();
    mockFirebaseAuth = MockFirebaseAuth();
    mockSharedPreferences = MockSharedPreferences();
    mockUserCredential = MockUserCredential();

    mockPhoneAuthCredential = MockPhoneAuthCredential();
    mockAuthProvider = MockAuthProvider(
        mockFirebaseAuth, mockSharedPreferences, mockPhoneAuthCredential);
    context = MockBuildContext();
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

      await tester.enterText(phoneTextField, '+60192620596');
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

      await tester.enterText(phoneTextField, '+60123451234');
      await tester.pumpAndSettle();

      final loginBtn = find.widgetWithText(ElevatedButton, 'Login').first;

      // Verify that loginBtn is enabled after phone number is entered
      expect(tester.widget<ElevatedButton>(loginBtn).enabled, isTrue);
      await tester.tap(loginBtn);
      await tester.pumpAndSettle();

      verify(() => mockController.showUnapprovedError(any())).called(1);
    });

    test('Send OTP to registered phone number', () async {
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

      mockAuthProvider.signInWithPhone(
        context,
        mockPhoneNumber,
        'UserType',
        'Purpose',
      );
      await mockFirebaseAuth
          .authStateChanges()
          .firstWhere((user) => user != null);

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

    test('OTP verification succeeds with correct OTP', () async {
      const verificationId = '11111';
      const userOTP = '123456';

      final mockUser = MockUser();
      final mockResult = MockUserCredential();

      when(() => mockFirebaseAuth.signInWithCredential(mockPhoneAuthCredential))
          .thenAnswer((_) async => mockResult);
      when(() => mockResult.user).thenReturn(mockUser);

      bool onSuccessCalled = false;
      void onSuccess() {
        onSuccessCalled = true;
      }

      await mockAuthProvider.verifyOTP(
        context: context,
        verificationId: verificationId,
        userOTP: userOTP,
        onSuccess: onSuccess,
      );

      verify(() =>
              mockFirebaseAuth.signInWithCredential(mockPhoneAuthCredential))
          .called(1);
      expect(onSuccessCalled, true);
    });

    test('OTP verification fails with incorrect OTP', () async {
      const verificationId = '11111';
      const userOTP = '654321';

      when(() => mockFirebaseAuth.signInWithCredential(mockPhoneAuthCredential))
          .thenThrow(FirebaseAuthException(code: 'invalid-otp'));

      bool onSuccessCalled = false;
      void onSuccess() {
        onSuccessCalled = true;
      }

      await mockAuthProvider.verifyOTP(
        context: context,
        verificationId: verificationId,
        userOTP: userOTP,
        onSuccess: onSuccess,
      );

      verify(() =>
              mockFirebaseAuth.signInWithCredential(mockPhoneAuthCredential))
          .called(1);
      expect(onSuccessCalled, false);
    });

    test('User logout succeed', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {
        return Future.value();
      });
      when(() => mockSharedPreferences.clear()).thenAnswer((_) async {
        return true;
      });

      await mockAuthProvider.userSignOut();

      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockSharedPreferences.clear()).called(1);
    });

    test('User logout failed', () async {
      when(() => mockFirebaseAuth.signOut())
          .thenThrow(Exception('Sign out failed'));

      expect(
        () async => await mockAuthProvider.userSignOut(),
        throwsA(isA<Exception>()),
      );

      verify(() => mockFirebaseAuth.signOut()).called(1);
      verifyNever(() => mockSharedPreferences.clear());
    });
  });
}

class MockAuthProvider extends Mock implements AuthProvider {
  final MockFirebaseAuth _firebaseAuth;
  final MockSharedPreferences sp;
  final MockPhoneAuthCredential _phoneAuthCredential;
  bool _isCustomerSignedIn = false;
  bool _isTechnicianSignedIn = false;
  bool _isLoading = false;

  MockAuthProvider(this._firebaseAuth, this.sp, this._phoneAuthCredential);

  @override
  Future userSignOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Sign out failed');
    }

    _isCustomerSignedIn = false;
    _isTechnicianSignedIn = false;

    notifyListeners();
    sp.clear();
  }

  @override
  Future<void> verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential result =
          await _firebaseAuth.signInWithCredential(_phoneAuthCredential);
      User? user = result.user;

      if (user != null) {
        _isLoading = false;

        notifyListeners();
        onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
