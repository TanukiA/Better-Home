import 'dart:async';
import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/views/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_home/utils.dart';

class AuthProvider extends ChangeNotifier {
  String? _uid;
  int? _forceResendingToken;
  bool _isSignedIn = false;
  bool _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  String get uid => _uid!;

  AuthProvider() {
    checkSign();
  }

  void checkSign() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }
/*
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  verificationId: verificationId,
                  controller: LoginController(),
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      await _firebaseAuth.signInWithCredential(creds);

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user!;

      _uid = user.uid;
      onSuccess();

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "Invalid OTP. Please try again.");
    }
  }
  */

  void signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) async {
            _forceResendingToken = forceResendingToken;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  verificationId: verificationId,
                  controller: LoginController(),
                  onResendPressed: () => resendOTP(),
                ),
              ),
            );
          },
          codeAutoRetrievalTimeout: (verificationId) {});
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, e.message.toString());
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
    required Function onSuccess,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);
      await _firebaseAuth.signInWithCredential(creds);

      User? user = (await _firebaseAuth.signInWithCredential(creds)).user!;

      _uid = user.uid;
      onSuccess();

      _isLoading = false;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      showSnackBar(context, "Invalid OTP. Please try again.");
    }
  }

  Future<bool> resendOTP() async {
    try {
      String? phoneNumber = _firebaseAuth.currentUser?.phoneNumber;
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber!,
          forceResendingToken: _forceResendingToken!,
          verificationCompleted:
              (PhoneAuthCredential phoneAuthCredential) async {
            await _firebaseAuth.signInWithCredential(phoneAuthCredential);
          },
          verificationFailed: (error) {
            throw Exception(error.message);
          },
          codeSent: (verificationId, forceResendingToken) {
            // Save the new forceResendingToken
            _forceResendingToken = forceResendingToken;
          },
          codeAutoRetrievalTimeout: (verificationId) {});

      return true;
    } on FirebaseAuthException catch (e) {
      return false;
    }
  }
}
