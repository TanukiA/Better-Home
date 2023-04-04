import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:authentication/models/form_input_provider.dart';

class Database extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  Future<bool> checkAccountExistence(
      String phoneNumber, String collectionName) async {
    final querySnapshot = await _firebaseFirestore
        .collection(collectionName)
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<bool> checkApprovalStatus(String phoneNumber) async {
    final querySnapshot = await _firebaseFirestore
        .collection("technicians")
        .where('phoneNumber', isEqualTo: phoneNumber)
        .where('approvalStatus', isEqualTo: true)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }

  Future<void> addCustomerData(Map<String, dynamic> customerData) async {
    await _firebaseFirestore
        .collection('customers')
        .add(customerData)
        .then((value) => print('Customer added'))
        .catchError((error) => print('Failed to add customer: $error'));
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>>
      getCustomerByPhoneNumber(String phoneNumber) async {
    final customersRef = FirebaseFirestore.instance.collection('customers');
    final querySnapshot = await customersRef
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    final documentSnapshot = querySnapshot.docs.first;
    return documentSnapshot;
  }

  Future<void> addTechnicianData(
      Map<String, dynamic> technicianData, PlatformFile pickedFile) async {
    try {
      DocumentReference documentReference = await _firebaseFirestore
          .collection('technicians')
          .add(technicianData);

      if (documentReference != null && pickedFile != null) {
        uploadFile(documentReference.id, pickedFile);
      }
    } catch (e) {
      print('Failed to add technician: $e');
    }
  }

  Future<void> uploadFile(String documentID, PlatformFile pickedFile) async {
    final path = 'files/${pickedFile.name}';
    final file = File(pickedFile.path!);

    final ref = _firebaseStorage.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    _firebaseFirestore.collection('technicians').doc(documentID).update({
      'pickedFile': downloadUrl,
    });
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>>
      getTechnicianByPhoneNumber(String phoneNumber) async {
    final techniciansRef = FirebaseFirestore.instance.collection('technicians');
    final querySnapshot = await techniciansRef
        .where('phoneNumber', isEqualTo: phoneNumber)
        .limit(1)
        .get();
    final documentSnapshot = querySnapshot.docs.first;
    return documentSnapshot;
  }
}
