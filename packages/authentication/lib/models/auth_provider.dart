import 'dart:async';
import 'dart:convert';
import 'package:authentication/controllers/login_controller.dart';
import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/views/verification_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:better_home/utils.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _userData;
  int? _forceResendingToken;
  bool _isSignedIn = false;
  bool _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  bool get isSignedIn => _isSignedIn;
  bool get isLoading => _isLoading;
  Map<String, dynamic> get userData => _userData!;

  AuthProvider() {
    checkSignIn();
  }

  void checkSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isSignedIn = s.getBool("is_signedin") ?? false;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber,
      String userType, String purpose) async {
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
            print("verificationId before: $verificationId");

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerificationScreen(
                  verificationId: verificationId,
                  loginCon: LoginController(),
                  registerCon: RegistrationController(),
                  userType: userType,
                  purpose: purpose,
                  phoneNumber: phoneNumber,
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
      print("verificationId after: $verificationId");
      print("userOTP: $userOTP");
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);

      UserCredential result = await _firebaseAuth.signInWithCredential(creds);
      User? user = result.user;

      if (user != null) {
        _isLoading = false;

        notifyListeners();
        onSuccess();
      } else {
        throw Exception("User is null");
      }
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, "Invalid OTP. Please try again.");
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, "Error: ${e.toString()}");
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
    } on FirebaseAuthException catch (e) {
      return false;
    }
    return true;
  }

  Future storeUserDataToSP(
      Map<String, dynamic> userData, String dataName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(dataName, jsonEncode(userData));
  }

  Future getUserDataFromSP(String dataName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final userDataJson = sp.getString(dataName);
    _userData = jsonDecode(userDataJson!);
    notifyListeners();
  }

  Future setSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("is_signedin", true);
    _isSignedIn = true;
    notifyListeners();
  }

  Future userSignOut() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isSignedIn = false;
    notifyListeners();
    sp.clear();
  }
}
