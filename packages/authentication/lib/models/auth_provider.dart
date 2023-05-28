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
  int? _forceResendingToken;
  bool _isCustomerSignedIn = false;
  bool _isTechnicianSignedIn = false;
  bool _isLoading = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  bool get isCustomerSignedIn => _isCustomerSignedIn;
  bool get isTechnicianSignedIn => _isTechnicianSignedIn;
  bool get isLoading => _isLoading;

  AuthProvider() {
    checkCustomerSignIn();
    checkTechnicianSignIn();
  }

  set setForceResendingToken(int value) {
    _forceResendingToken = value;
  }

  void checkCustomerSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isCustomerSignedIn = s.getBool("is_customer_signedin") ?? false;
    notifyListeners();
  }

  Future setCustomerSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("is_customer_signedin", true);
    _isCustomerSignedIn = true;
    notifyListeners();
  }

  void checkTechnicianSignIn() async {
    final SharedPreferences s = await SharedPreferences.getInstance();
    _isTechnicianSignedIn = s.getBool("is_technician_signedin") ?? false;
    notifyListeners();
  }

  Future setTechnicianSignIn() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool("is_technician_signedin", true);
    _isTechnicianSignedIn = true;
    notifyListeners();
  }

  void signInWithPhone(BuildContext context, String phoneNumber,
      String userType, String purpose) async {
    try {
      User? currentUser = _firebaseAuth.currentUser;
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
                  loginCon: LoginController(userType),
                  registerCon: RegistrationController(userType),
                  userType: userType,
                  purpose: purpose,
                  phoneNumber: phoneNumber,
                  onResendPressed: () => resendOTP(phoneNumber),
                  currentUser: currentUser,
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

      UserCredential result = await _firebaseAuth.signInWithCredential(creds);
      User? user = result.user;

      if (user != null) {
        _isLoading = false;

        notifyListeners();
        onSuccess();
      }
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, "Invalid OTP. Please try again.");
    }
  }

  Future<bool> resendOTP(String phoneNumber) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
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

  void verifyPhoneNumberUpdate({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
    required Function onSuccess,
    required User currentUser,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      PhoneAuthCredential creds = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: userOTP);

      await currentUser.updatePhoneNumber(creds);

      _isLoading = false;
      notifyListeners();
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      notifyListeners();
      showSnackBar(context, "Invalid OTP. Please try again.");
    }
  }

  Future storeUserDataToSP(
      Map<String, dynamic> userData, String dataName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(dataName, jsonEncode(userData));
  }

  Future<String> getUserIDFromSP(String dataName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final userDataJson = sp.getString(dataName);
    notifyListeners();
    final userData = jsonDecode(userDataJson!);
    print("ID: ${userData['id']}");

    return userData['id'];
  }

  Future<String> getUserNameFromSP(String dataName) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    final userDataJson = sp.getString(dataName);
    notifyListeners();
    final userData = jsonDecode(userDataJson!);

    return userData['name'];
  }

  Future userSignOut() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await _firebaseAuth.signOut();
    _isCustomerSignedIn = false;
    _isTechnicianSignedIn = false;

    notifyListeners();
    sp.clear();
  }
}
