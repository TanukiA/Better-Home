import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:core';

class Database extends ChangeNotifier {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  static List<String> overlappedTechnicianIDs = [];

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

      if (pickedFile != PlatformFile(name: '', size: 0)) {
        uploadFile(documentReference.id, pickedFile);
      }
    } catch (e) {
      print('Failed to add technician: $e');
    }
  }

  Future<void> uploadFile(String documentID, PlatformFile pickedFile) async {
    final path = 'technicianDoc/${pickedFile.name}';
    final file = File(pickedFile.path!);

    final ref = _firebaseStorage.ref().child(path);
    UploadTask uploadTask = ref.putFile(file);
    final taskSnapshot = await uploadTask.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    _firebaseFirestore.collection('technicians').doc(documentID).update({
      'verificationDoc': downloadUrl,
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

  Future<int> getTechnicianQtyMatched(
      String serviceCategory, String city) async {
    final querySnapshot = await _firebaseFirestore
        .collection('technicians')
        .where('specialization', arrayContains: serviceCategory)
        .where('city', isEqualTo: city)
        .get();
    return querySnapshot.size;
  }

  // Check technician's availability for one given time slot, return true/false represents available/not available
  Future<bool> checkTechnicianAvailability(
      String serviceCategory,
      String city,
      DateTime date,
      DateTime timeSlotStart,
      DateTime timeSlotEnd,
      int matchedQty) async {
    final techniciansQuerySnapshot = await _firebaseFirestore
        .collection("technicians")
        .where("specialization", arrayContains: serviceCategory)
        .where("city", isEqualTo: city)
        .get();
    int countOverlap = 0;

    for (final technicianDoc in techniciansQuerySnapshot.docs) {
      final workSchedulesCollection =
          technicianDoc.reference.collection("work_schedules");
      final workSchedulesQuerySnapshot = await workSchedulesCollection.get();

      if (workSchedulesQuerySnapshot.docs.isEmpty) {
        continue;
      }

      for (final workScheduleDoc in workSchedulesQuerySnapshot.docs) {
        final temp = workScheduleDoc.get("startTime").toDate().toLocal();
        final workDate = DateTime(temp.year, temp.month, temp.day);

        if (date == workDate) {
          DateTime startTime = workScheduleDoc.get("startTime").toDate();
          DateTime endTime = workScheduleDoc.get("endTime").toDate();
          // Check if the preferred time slot overlaps with the start and end time
          // Increment number of overlapped technician, and store the document ID to be used later for filtering out
          if ((timeSlotStart.isAfter(startTime) &&
                  timeSlotStart.isBefore(endTime)) ||
              (timeSlotEnd.isAfter(startTime) &&
                  timeSlotEnd.isBefore(endTime))) {
            countOverlap++;
            overlappedTechnicianIDs.add(technicianDoc.id);
            break;
          }
        }
      }
    }
    if (countOverlap < matchedQty) {
      return true;
    } else {
      return false;
    }
  }

  List<Map<String, dynamic>> getLocationOfAvailableTechnician(
      String serviceCategory, String city) {
    print("Overlapped Technician IDs: $overlappedTechnicianIDs");

    List<Map<String, dynamic>> techniciansData = [];
    CollectionReference techniciansCollection =
        _firebaseFirestore.collection('technicians');

    techniciansCollection
        .where("specialization", arrayContains: serviceCategory)
        .where("city", isEqualTo: city)
        .where(FieldPath.documentId, whereNotIn: overlappedTechnicianIDs)
        .get()
        .then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        final technicianData = {'id': doc.id, 'location': doc.get('location')};
        techniciansData.add(technicianData);
      }
    });
    print("Technicians to be chosen: $techniciansData");
    return techniciansData;
  }
}
