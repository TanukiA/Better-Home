import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:core';
import 'package:photo_view/photo_view.dart';

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
    try {
      await _firebaseFirestore.collection('customers').add(customerData);
    } catch (e) {
      throw PlatformException(
          code: 'add-customer-failed', message: e.toString());
    }
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
      throw PlatformException(
          code: 'add-technician-failed', message: e.toString());
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

  Future<List<Map<String, dynamic>>> getLocationOfAvailableTechnician(
      String serviceCategory, String city) async {
    print("Overlapped Technician IDs: $overlappedTechnicianIDs");

    List<Map<String, dynamic>> techniciansData = [];
    CollectionReference techniciansCollection =
        _firebaseFirestore.collection('technicians');

    if (overlappedTechnicianIDs.isNotEmpty) {
      await techniciansCollection
          .where("specialization", arrayContains: serviceCategory)
          .where("city", isEqualTo: city)
          .where(FieldPath.documentId, whereNotIn: overlappedTechnicianIDs)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          final technicianData = {
            'id': doc.id,
            'location': doc.get('location')
          };
          techniciansData.add(technicianData);
        }
      });
    } else {
      await techniciansCollection
          .where("specialization", arrayContains: serviceCategory)
          .where("city", isEqualTo: city)
          .get()
          .then((QuerySnapshot querySnapshot) {
        for (var doc in querySnapshot.docs) {
          final technicianData = {
            'id': doc.id,
            'location': doc.get('location')
          };
          techniciansData.add(technicianData);
        }
      });
    }
    print("City: $city");
    print("Specialization: $serviceCategory");
    return techniciansData;
  }

  Future<void> storeServiceRequest(
      Map<String, dynamic> data, List<XFile>? imgFiles) async {
    try {
      final CollectionReference servicesRef =
          _firebaseFirestore.collection('services');
      final DocumentReference serviceDocRef = await servicesRef.add(data);

      final List<String>? downloadUrls = imgFiles != null
          ? await uploadServiceImages(serviceDocRef, imgFiles)
          : null;
      if (downloadUrls != null) {
        await serviceDocRef.update({'images': downloadUrls});
      }
    } catch (e) {
      throw PlatformException(
          code: 'add-service-request-failed', message: e.toString());
    }
  }

  Future<List<String>> uploadServiceImages(
      DocumentReference serviceDocRef, List<XFile> imgFiles) async {
    final List<String> downloadUrls = [];
    try {
      // Upload each image to Cloud Storage, add its download URL to the "images" array in the "services"
      await Future.wait(
        imgFiles.map(
          (XFile imgFile) async {
            // Generate a unique ID for the image
            final String imgId =
                DateTime.now().microsecondsSinceEpoch.toString();
            final String extension = path.extension(imgFile.path);
            final String imgPath =
                'services/${serviceDocRef.id}/$imgId$extension';

            final Reference storageRef = _firebaseStorage.ref().child(imgPath);
            final TaskSnapshot taskSnapshot = await storageRef.putFile(
              File(imgFile.path),
              SettableMetadata(
                contentType: 'image/${extension.substring(1)}',
              ),
            );

            final String downloadUrl = await taskSnapshot.ref.getDownloadURL();
            downloadUrls.add(downloadUrl);
          },
        ),
      );

      return downloadUrls;
    } catch (e) {
      throw PlatformException(
          code: 'upload-image-failed', message: e.toString());
    }
  }

  Future<List<QueryDocumentSnapshot>> readActiveServices(String id) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('services')
        .where('customerID', isEqualTo: id)
        .where('serviceStatus',
            whereIn: ['Assigning', 'Confirmed', 'In Progress']).get();
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    return documents;
  }

  Future<List<Widget>> downloadServiceImages(
      QueryDocumentSnapshot serviceDoc) async {
    List<String> imageRefs =
        (serviceDoc.data() as Map<String, dynamic>)['images'].cast<String>();

    if (imageRefs.isNotEmpty) {
      // Download the images from Cloud Storage and store them in a list of PhotoView
      List<Future<Widget>> imageFutures = imageRefs.map((imageRef) async {
        return SizedBox(
          width: 300.0,
          height: 250.0,
          child: PhotoView(
            imageProvider: NetworkImage(imageRef),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.5,
          ),
        );
      }).toList();

      Iterable<Future<Widget>> imageIterable = imageFutures;
      List<Widget> images = await Future.wait(imageIterable);
      return images;
    }
    return [];
  }

  Future<String> readTechnicianName(QueryDocumentSnapshot serviceDoc) async {
    final CollectionReference techniciansRef =
        _firebaseFirestore.collection('technicians');
    final String technicianID = serviceDoc['technicianID'];
    final DocumentSnapshot technicianDoc =
        await techniciansRef.doc(technicianID).get();
    return technicianDoc.get('name');
  }

  Future<List<QueryDocumentSnapshot>> readPastServices(String id) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('services')
        .where('customerID', isEqualTo: id)
        .where('serviceStatus',
            whereIn: ['Completed', 'Rated', 'Cancelled', 'Refunded']).get();
    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    return documents;
  }

  Future<Map<String, dynamic>> readServiceRating(String id) async {
    final ratingDocSnapshot =
        await _firebaseFirestore.collection('ratings').doc(id).get();

    if (!ratingDocSnapshot.exists) {
      return {'starQty': null, 'reviewText': null};
    }

    final ratingDoc = ratingDocSnapshot.data();
    final starQty = ratingDoc!['starQty']?.toDouble() ?? 0.0;
    final reviewText = ratingDoc['reviewText'] ?? '';

    return {'starQty': starQty, 'reviewText': reviewText};
  }

  Future<void> updateServiceCancelled(String serviceID) async {
    try {
      final servicesCollection = _firebaseFirestore.collection('services');
      final serviceDoc = servicesCollection.doc(serviceID);

      await serviceDoc.update({'serviceStatus': 'Cancelled'});
    } catch (e) {
      throw PlatformException(
          code: 'cancel-service-failed', message: e.toString());
    }
  }

  Future<void> storeServiceReview(double starQty, String reviewText, String id,
      String customerID, String technicianID) async {
    try {
      // store review
      await _firebaseFirestore.collection('ratings').doc(id).set({
        'starQty': starQty,
        'reviewText': reviewText,
        'customerID': customerID,
        'technicianID': technicianID,
      });
      // update service status to "Rated"
      final servicesCollection = _firebaseFirestore.collection('services');
      final serviceDoc = servicesCollection.doc(id);

      await serviceDoc.update({'serviceStatus': 'Rated'});
    } catch (e) {
      throw PlatformException(code: 'add-review-failed', message: e.toString());
    }
  }

  Future<List<QueryDocumentSnapshot<Object?>>> readAssignedServices(
      String id) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('services')
        .where('technicianID', isEqualTo: id)
        .where('serviceStatus', isEqualTo: 'Assigning')
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    return documents;
  }

  Future<String> readCustomerName(QueryDocumentSnapshot serviceDoc) async {
    final CollectionReference customersRef =
        _firebaseFirestore.collection('customers');
    final String customerID = serviceDoc['customerID'];
    final DocumentSnapshot customerDoc =
        await customersRef.doc(customerID).get();
    return customerDoc.get('name');
  }
}
