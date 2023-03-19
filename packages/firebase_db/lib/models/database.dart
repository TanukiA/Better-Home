import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class Firestore extends ChangeNotifier {
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

  Future<void> addTechnicianData(Map<String, dynamic> technicianData) async {
    await _firebaseFirestore
        .collection('technicians')
        .add(technicianData)
        .then((value) => print('Technician added'))
        .catchError((error) => print('Failed to add technician: $error'));
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
