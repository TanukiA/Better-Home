// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_data/models/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map/models/distance_calculator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:service/controllers/technician_controller.dart';
import 'package:service/models/service.dart';
import 'package:service/models/technician_assigner.dart';
import 'package:authentication/models/auth_provider.dart';
import 'package:intl/intl.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshotForSort extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  late Map<String, dynamic> _data;

  void setData(Map<String, dynamic> data) {
    _data = data;
  }

  @override
  Map<String, dynamic> data() => _data;
}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockBuildContext extends Fake implements BuildContext {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDistanceCalculator extends Mock implements DistanceCalculator {}

class MockAuthProvider extends Mock implements AuthProvider {}

main() {
  late MockFirebaseFirestore mockFirestore;
  late MockDatabase mockDatabase;
  late MockCollectionReference mockCollectionReference;
  late MockQuery mockQuery;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockBuildContext mockBuildContext;
  late MockQueryDocumentSnapshot mockQueryDocumentSnapshot;
  late MockDocumentReference mockDocumentReference;
  late MockDistanceCalculator mockDistanceCalculator;
  late MockTechnicianAssigner mockTechnicianAssigner;
  late MockService mockService;
  late MockTechnicianController mockTechnicianController;
  late MockAuthProvider mockAuthProvider;
  late MockDocumentSnapshot mockDocumentSnapshot;

  setUpAll(() {
    mockBuildContext = MockBuildContext();
    registerFallbackValue(MockBuildContext());
    registerFallbackValue(const GeoPoint(0, 0));
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockQuery = MockQuery();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDatabase = MockDatabase(mockFirestore);
    mockDistanceCalculator = MockDistanceCalculator();
    mockTechnicianAssigner =
        MockTechnicianAssigner(mockBuildContext, mockDatabase);
    mockAuthProvider = MockAuthProvider();
    mockService = MockService(mockDatabase, mockAuthProvider);
    mockTechnicianController =
        MockTechnicianController(mockService, mockDatabase);
  });

  group('Service Tracking by Customer', () {
    test('Retrieve active services (matching service found)', () async {
      final mockDocuments = List<MockQueryDocumentSnapshot>.generate(
        4,
        (index) => MockQueryDocumentSnapshot(),
      );

      mockCollectionReference = MockCollectionReference();

      // Set up the expected behavior of Firestore API calls
      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() =>
              mockCollectionReference.where('customerID', isEqualTo: 'ABC123'))
          .thenReturn(mockQuery);
      when(() =>
              mockQuery.where('serviceStatus', whereIn: any(named: 'whereIn')))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('dateTimeSubmitted', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocuments);

      final result = await mockDatabase.readActiveServices('ABC123');

      expect(result, mockDocuments);
    });

    test('Retrieve active services (no matching service found)', () async {
      final mockDocuments = List<MockQueryDocumentSnapshot>.generate(
        0,
        (index) => MockQueryDocumentSnapshot(),
      );

      mockCollectionReference = MockCollectionReference();

      // Set up the expected behavior of Firestore API calls
      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() =>
              mockCollectionReference.where('customerID', isEqualTo: 'DEF456'))
          .thenReturn(mockQuery);
      when(() =>
              mockQuery.where('serviceStatus', whereIn: any(named: 'whereIn')))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('dateTimeSubmitted', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocuments);

      final result = await mockDatabase.readActiveServices('DEF456');

      expect(result, isEmpty);
    });

    test('Retrieve past services (matching service found)', () async {
      final mockDocuments = List<MockQueryDocumentSnapshot>.generate(
        4,
        (index) => MockQueryDocumentSnapshot(),
      );

      mockCollectionReference = MockCollectionReference();

      // Set up the expected behavior of Firestore API calls
      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() =>
              mockCollectionReference.where('customerID', isEqualTo: 'ABC123'))
          .thenReturn(mockQuery);
      when(() =>
              mockQuery.where('serviceStatus', whereIn: any(named: 'whereIn')))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('dateTimeSubmitted', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocuments);

      final result =
          await mockDatabase.readPastServices('ABC123', 'customerID');

      expect(result, mockDocuments);
    });

    test('Retrieve past services (no matching service found)', () async {
      final mockDocuments = List<MockQueryDocumentSnapshot>.generate(
        0,
        (index) => MockQueryDocumentSnapshot(),
      );

      mockCollectionReference = MockCollectionReference();

      // Set up the expected behavior of Firestore API calls
      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() =>
              mockCollectionReference.where('customerID', isEqualTo: 'DEF456'))
          .thenReturn(mockQuery);
      when(() =>
              mockQuery.where('serviceStatus', whereIn: any(named: 'whereIn')))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('dateTimeSubmitted', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocuments);

      final result =
          await mockDatabase.readPastServices('DEF456', 'customerID');

      expect(result, isEmpty);
    });

    test('Cancel service in “Assigning” status', () async {
      mockCollectionReference = MockCollectionReference();
      mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      mockDocumentReference = MockDocumentReference();

      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc('saZERFQe9mmqJ15LTh25'))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.get())
          .thenAnswer((_) async => mockQueryDocumentSnapshot);
      when(() => mockQueryDocumentSnapshot.get('serviceStatus'))
          .thenReturn('Assigning');
      when(() => mockDocumentReference.update({'serviceStatus': 'Cancelled'}))
          .thenAnswer((_) async => Future<void>);

      await mockDatabase.updateServiceCancelled(
          'saZERFQe9mmqJ15LTh25', mockBuildContext);

      verify(() => mockFirestore.collection('services')).called(1);
      verify(() => mockCollectionReference.doc('saZERFQe9mmqJ15LTh25'))
          .called(1);
      verify(() => mockQueryDocumentSnapshot.get('serviceStatus')).called(1);
      verifyNever(() => mockQueryDocumentSnapshot.reference
          .collection('work_schedules')
          .doc('saZERFQe9mmqJ15LTh25')
          .delete());

      mockDatabase.updateCancelledStatus(
          'saZERFQe9mmqJ15LTh25', false, mockBuildContext);

      verify(() => mockDocumentReference.update({'serviceStatus': 'Cancelled'}))
          .called(1);
    });

    test(
        'Allow cancellation for service in “Confirmed” status with at least 12 hours before appointment time',
        () {
      final mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      // Confirmed date value must be changed according to current date
      final confirmedDate = Timestamp.fromDate(DateTime(2023, 8, 10));
      const confirmedTime = '10:00AM - 12:00PM';

      when(() => mockQueryDocumentSnapshot.data()).thenReturn({
        'confirmedDate': confirmedDate,
        'confirmedTime': confirmedTime,
      });

      final service = Service();
      final result = service.validTimeToCancel(mockQueryDocumentSnapshot);

      expect(result, true);
    });

    test(
        'Reject cancellation for service in “Confirmed” status with less than 12 hours before appointment time',
        () {
      mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();
      final confirmedDate = Timestamp.fromDate(DateTime(2023, 6, 10));
      const confirmedTime = '5:00PM - 7:00PM';

      when(() => mockQueryDocumentSnapshot.data()).thenReturn({
        'confirmedDate': confirmedDate,
        'confirmedTime': confirmedTime,
      });

      final service = Service();
      final result = service.validTimeToCancel(mockQueryDocumentSnapshot);

      expect(result, false);
    });

    test('Store star rating and review (positive case)', () async {
      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();

      const id = 'JSkSmTOIJHM5zlAjDDzP';
      const starQty = 4.0;
      const reviewText = 'Great service quality';
      const customerID = 'ABC123';
      const technicianID = 'DEF456';

      when(() => mockFirestore.collection('ratings'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc(id))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.set(any()))
          .thenAnswer((_) async => Future<void>);
      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockDocumentReference.update({'serviceStatus': 'Rated'}))
          .thenAnswer((_) async => Future<void>);

      await mockDatabase.storeServiceReview(
          starQty, reviewText, id, customerID, technicianID);

      verify(() => mockFirestore.collection('ratings')).called(1);
      verify(() => mockDocumentReference.set({
            'starQty': starQty,
            'reviewText': reviewText,
            'customerID': customerID,
            'technicianID': technicianID,
          })).called(1);
      verify(() => mockFirestore.collection('services')).called(1);
      verify(() => mockDocumentReference.update({'serviceStatus': 'Rated'}))
          .called(1);
    });

    test('Store star rating and review (negative case)', () async {
      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();

      const id = 'JSkSmTOIJHM5zlAjDDzP';
      const starQty = 4.0;
      const reviewText = 'Great service quality';
      const customerID = 'ABC123';
      const technicianID = 'DEF456';

      when(() => mockFirestore.collection('ratings'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc(id))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.set(any())).thenThrow(PlatformException(
          code: 'add-review-failed', message: 'Exception occurred.'));

      expect(() async {
        await mockDatabase.storeServiceReview(
            starQty, reviewText, id, customerID, technicianID);
      }, throwsA(isA<PlatformException>()));
    });
  });

  group('Service Tracking by Technician', () {
    test('Retrieve assigned services (matching service found)', () async {
      mockCollectionReference = MockCollectionReference();

      final mockDocuments = List<MockQueryDocumentSnapshot>.generate(
        3,
        (index) => MockQueryDocumentSnapshot(),
      );

      const technicianID = 'ABC123';

      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.where('technicianID',
          isEqualTo: technicianID)).thenReturn(mockQuery);
      when(() => mockQuery.where('serviceStatus', isEqualTo: 'Assigning'))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('dateTimeSubmitted', descending: false))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocuments);

      final result = await mockDatabase.readAssignedServices(technicianID);

      expect(result, mockDocuments);
    });

    test('Retrieve assigned services (no matching service found)', () async {
      mockCollectionReference = MockCollectionReference();

      final mockDocuments = List<MockQueryDocumentSnapshot>.generate(
        0,
        (index) => MockQueryDocumentSnapshot(),
      );

      const technicianID = 'DEF456';

      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.where('technicianID',
          isEqualTo: technicianID)).thenReturn(mockQuery);
      when(() => mockQuery.where('serviceStatus', isEqualTo: 'Assigning'))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('dateTimeSubmitted', descending: false))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocuments);

      final result = await mockDatabase.readAssignedServices(technicianID);

      expect(result, isEmpty);
    });

    test('Update service request accepted', () async {
      const serviceId = 'saZERFQe9mmqJ15LTh25';
      final date = Timestamp.fromDate(DateTime(2023, 8, 10));
      const timeSlot = '10:00AM - 12:00PM';

      mockCollectionReference = MockCollectionReference();
      mockDocumentReference = MockDocumentReference();
      mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc(serviceId))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.id).thenReturn(serviceId);
      when(() => mockDocumentReference.update({'serviceStatus': 'Confirmed'}))
          .thenAnswer((_) async => Future<void>);
      when(() => mockDocumentReference.get())
          .thenAnswer((_) async => mockQueryDocumentSnapshot);
      when(() => mockQueryDocumentSnapshot.get('assignedDate'))
          .thenReturn(date);
      when(() => mockQueryDocumentSnapshot.get('assignedTime'))
          .thenReturn(timeSlot);
      when(() => mockDocumentReference.update({
            'confirmedDate': date,
            'confirmedTime': timeSlot,
          })).thenAnswer((_) async => Future<void>);
      when(() => mockDocumentReference.update({
            'assignedDate': FieldValue.delete(),
            'assignedTime': FieldValue.delete(),
          })).thenAnswer((_) async => Future<void>);

      await mockDatabase.updateAcceptRequest(serviceId, 'ABC123',
          'Painting - Exterior Painting', 'Anthony Fong An Tian');

      verify(() => mockFirestore.collection('services')).called(2);
      verify(() => mockCollectionReference.doc(serviceId)).called(2);
      verify(() => mockDocumentReference.update({'serviceStatus': 'Confirmed'}))
          .called(1);
      verify(() => mockDocumentReference.update({
            'confirmedDate': date,
            'confirmedTime': timeSlot,
          })).called(1);
      verify(() => mockDocumentReference.update({
            'assignedDate': FieldValue.delete(),
            'assignedTime': FieldValue.delete(),
          })).called(1);
    });

    test('Find new technician to assign rejected service request', () async {
      const serviceCategory = 'Painting';
      const city = 'Melaka';
      const serviceLocation = GeoPoint(40.7128, -74.0060);
      const nearestTechnicianID = 'ABC123';

      when(() => mockDatabase.getLocationOfAvailableTechnician(
          serviceCategory, city)).thenAnswer(
        (_) async => [
          {
            'id': nearestTechnicianID,
            'location': const GeoPoint(40.7127, -74.0061),
          },
        ],
      );

      when(() =>
              mockDistanceCalculator.getNearestTechnicianLocation(any(), any()))
          .thenReturn(
        const GeoPoint(40.7127, -74.0061),
      );

      final result = await mockTechnicianAssigner.pickReassignTechnician(
          serviceCategory, city, serviceLocation);

      expect(result, nearestTechnicianID);
    });

    test('Assign technician using preferred appointment', () async {
      mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

      const serviceID = "12345";
      const preferredTechnicianID = "DEF456";
      const alternativeTechnicianID = "GHI789";

      when(() => mockQueryDocumentSnapshot.id).thenReturn(serviceID);

      when(() => mockQueryDocumentSnapshot.data()).thenReturn({
        "technicianID": "ABC123",
        "preferredDate": Timestamp.fromDate(DateTime(2023, 6, 14)),
        "alternativeDate": Timestamp.fromDate(DateTime(2023, 6, 15)),
        "preferredTime": "10:00AM - 12:00PM",
        "alternativeTime": "5:00PM - 7:00PM",
        "serviceName": "Roof Servicing - Shingle/Tile Replacement",
        "city": "Pahang",
        "location": const GeoPoint(40.7128, -74.0060),
      });

      when(() => mockService.processTechnicianReassign(
          any(),
          any(),
          any(),
          any(),
          any(),
          DateTime(2023, 6, 14),
          "10:00AM - 12:00PM")).thenAnswer((_) async => preferredTechnicianID);

      when(() => mockDatabase.updateTechnicianReassigned(
          serviceID,
          preferredTechnicianID,
          DateTime(2023, 6, 14),
          "10:00AM - 12:00PM")).thenAnswer((_) => Future.value());

      await mockTechnicianController.rejectIconPressed(
          mockQueryDocumentSnapshot, mockBuildContext);

      verify(() => mockDatabase.updateTechnicianReassigned(
          serviceID,
          preferredTechnicianID,
          DateTime(2023, 6, 14),
          "10:00AM - 12:00PM")).called(1);

      verifyNever(() => mockDatabase.updateTechnicianReassigned(serviceID,
          alternativeTechnicianID, DateTime(2023, 6, 15), "5:00PM - 7:00PM"));
    });

    test('Assign technician using alternative appointment', () async {
      mockQueryDocumentSnapshot = MockQueryDocumentSnapshot();

      const serviceID = "12345";
      const preferredTechnicianID = "DEF456";
      const alternativeTechnicianID = "GHI789";

      when(() => mockQueryDocumentSnapshot.id).thenReturn(serviceID);

      when(() => mockQueryDocumentSnapshot.data()).thenReturn({
        "technicianID": "ABC123",
        "preferredDate": Timestamp.fromDate(DateTime(2023, 6, 14)),
        "alternativeDate": Timestamp.fromDate(DateTime(2023, 6, 15)),
        "preferredTime": "10:00AM - 12:00PM",
        "alternativeTime": "5:00PM - 7:00PM",
        "serviceName": "Roof Servicing - Shingle/Tile Replacement",
        "city": "Pahang",
        "location": const GeoPoint(40.7128, -74.0060),
      });

      when(() => mockService.processTechnicianReassign(
          any(),
          any(),
          any(),
          any(),
          any(),
          DateTime(2023, 6, 14),
          "10:00AM - 12:00PM")).thenAnswer((_) async => "");

      when(() => mockService.processTechnicianReassign(
          any(),
          any(),
          any(),
          any(),
          any(),
          DateTime(2023, 6, 15),
          "5:00PM - 7:00PM")).thenAnswer((_) async => alternativeTechnicianID);

      when(() => mockDatabase.updateTechnicianReassigned(
          serviceID,
          alternativeTechnicianID,
          DateTime(2023, 6, 15),
          "5:00PM - 7:00PM")).thenAnswer((_) => Future.value());

      await mockTechnicianController.rejectIconPressed(
          mockQueryDocumentSnapshot, mockBuildContext);

      verifyNever(() => mockDatabase.updateTechnicianReassigned(serviceID,
          preferredTechnicianID, DateTime(2023, 6, 14), "10:00AM - 12:00PM"));

      verify(() => mockDatabase.updateTechnicianReassigned(
          serviceID,
          alternativeTechnicianID,
          DateTime(2023, 6, 15),
          "5:00PM - 7:00PM")).called(1);
    });

    test('Sort service appointments by confirmed time slot', () async {
      final mockSnapshot1 = MockQueryDocumentSnapshotForSort();
      final mockSnapshot2 = MockQueryDocumentSnapshotForSort();
      final mockSnapshot3 = MockQueryDocumentSnapshotForSort();
      mockSnapshot1.setData({
        'confirmedTime': '10:00AM - 12:00PM',
        'serviceName': 'Aircon Servicing - Aircon Cleaning & Inspection'
      });
      mockSnapshot2.setData({
        'confirmedTime': '3:00PM - 5:00PM',
        'serviceName': 'Aircon Servicing - Aircon Repair / Install'
      });
      mockSnapshot3.setData({
        'confirmedTime': '5:00PM - 7:00PM',
        'serviceName': 'Aircon Servicing - Aircon Cleaning & Inspection'
      });

      final unsortedList = [mockSnapshot3, mockSnapshot2, mockSnapshot1];
      final expectedSortedList = [mockSnapshot1, mockSnapshot2, mockSnapshot3];

      when(() => mockAuthProvider.getUserIDFromSP(any()))
          .thenAnswer((_) async => 'ABC123');

      when(() => mockDatabase.readWorkData(any())).thenAnswer((_) async {
        List<QueryDocumentSnapshot<Object?>> querySnapshots = unsortedList;
        return querySnapshots;
      });

      final result =
          await mockService.retrieveWorkScheduleData(mockBuildContext);

      verify(() => mockAuthProvider.getUserIDFromSP('session_data')).called(1);
      verify(() => mockDatabase.readWorkData('ABC123')).called(1);

      expect(result, expectedSortedList);
    });

    test('Retrieve past services (matching service found)', () async {
      final mockDocuments = List<MockQueryDocumentSnapshot>.generate(
        4,
        (index) => MockQueryDocumentSnapshot(),
      );

      mockCollectionReference = MockCollectionReference();

      // Set up the expected behavior of Firestore API calls
      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.where('technicianID',
          isEqualTo: 'ABC123')).thenReturn(mockQuery);
      when(() =>
              mockQuery.where('serviceStatus', whereIn: any(named: 'whereIn')))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('dateTimeSubmitted', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocuments);

      final result =
          await mockDatabase.readPastServices('ABC123', 'technicianID');

      expect(result, mockDocuments);
    });

    test('Retrieve past services (no matching service found)', () async {
      final mockDocuments = List<MockQueryDocumentSnapshot>.generate(
        0,
        (index) => MockQueryDocumentSnapshot(),
      );

      mockCollectionReference = MockCollectionReference();

      // Set up the expected behavior of Firestore API calls
      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.where('technicianID',
          isEqualTo: 'DEF456')).thenReturn(mockQuery);
      when(() =>
              mockQuery.where('serviceStatus', whereIn: any(named: 'whereIn')))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy('dateTimeSubmitted', descending: true))
          .thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(mockDocuments);

      final result =
          await mockDatabase.readPastServices('DEF456', 'technicianID');

      expect(result, isEmpty);
    });

    test('Change service status', () async {
      const serviceID = '12345';
      const newStatus = 'Completed';
      final serviceSnapshotData = {
        'serviceName': 'Roof Servicing - Shingle/Tile Replacement',
        'serviceStatus': 'In Progress',
      };
      mockDocumentReference = MockDocumentReference();
      mockCollectionReference = MockCollectionReference();
      mockDocumentSnapshot = MockDocumentSnapshot();

      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc(serviceID))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.get())
          .thenAnswer((_) async => mockDocumentSnapshot);
      when(() => mockDocumentSnapshot.data()).thenReturn(serviceSnapshotData);
      when(() => mockDocumentReference.update(any()))
          .thenAnswer((_) async => Future<void>);

      await mockDatabase.updateServiceStatus(
          serviceID, newStatus, mockBuildContext);

      verify(() => mockFirestore.collection('services')).called(1);
      verify(() => mockCollectionReference.doc(serviceID)).called(1);
      verify(() => mockDocumentReference.get()).called(1);
      verify(() => mockDocumentReference.update({'serviceStatus': newStatus}))
          .called(1);
    });
  });
}

class MockDatabase extends Mock implements Database {
  final MockFirebaseFirestore _firebaseFirestore;
  static List<String> unavailableTechnicianIDs = [];

  MockDatabase(this._firebaseFirestore);

  @override
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> readActiveServices(
      String id) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firebaseFirestore
        .collection('services')
        .where('customerID', isEqualTo: id)
        .where('serviceStatus',
            whereIn: ['Assigning', 'Confirmed', 'In Progress'])
        .orderBy('dateTimeSubmitted', descending: true)
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;
    return documents;
  }

  @override
  Future<List<QueryDocumentSnapshot>> readPastServices(
      String id, String idType) async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firebaseFirestore
        .collection('services')
        .where(idType, isEqualTo: id)
        .where('serviceStatus',
            whereIn: ['Completed', 'Rated', 'Cancelled', 'Refunded'])
        .orderBy('dateTimeSubmitted', descending: true)
        .get();

    List<QueryDocumentSnapshot<Map<String, dynamic>>> documents =
        querySnapshot.docs;
    return documents;
  }

  @override
  Future<void> updateServiceCancelled(String serviceID, BuildContext context,
      [String technicianID = ""]) async {
    final serviceDoc =
        await _firebaseFirestore.collection('services').doc(serviceID).get();

    final serviceStatus = serviceDoc.get('serviceStatus');

    if (serviceStatus == 'Confirmed') {
      final technicianDoc = await _firebaseFirestore
          .collection('technicians')
          .doc(technicianID)
          .get();

      final workScheduleDoc =
          technicianDoc.reference.collection('work_schedules').doc(serviceID);
      await workScheduleDoc.delete();
    }
  }

  @override
  Future<void> updateCancelledStatus(
      String id, bool sendNoti, BuildContext context) async {
    try {
      final servicesCollection = _firebaseFirestore.collection('services');
      final serviceDoc = servicesCollection.doc(id);
      await serviceDoc.update({'serviceStatus': 'Cancelled'});
    } catch (e) {
      throw PlatformException(
          code: 'update-status-failed', message: e.toString());
    }
  }

  @override
  Future<void> storeServiceReview(double starQty, String? reviewText, String id,
      String customerID, String technicianID) async {
    try {
      await _firebaseFirestore.collection('ratings').doc(id).set({
        'starQty': starQty,
        'reviewText': reviewText,
        'customerID': customerID,
        'technicianID': technicianID,
      });

      final servicesCollection = _firebaseFirestore.collection('services');
      final serviceDoc = servicesCollection.doc(id);

      await serviceDoc.update({'serviceStatus': 'Rated'});
    } catch (e) {
      throw PlatformException(code: 'add-review-failed', message: e.toString());
    }
  }

  @override
  Future<List<QueryDocumentSnapshot<Object?>>> readAssignedServices(
      String id) async {
    QuerySnapshot querySnapshot = await _firebaseFirestore
        .collection('services')
        .where('technicianID', isEqualTo: id)
        .where('serviceStatus', isEqualTo: 'Assigning')
        .orderBy('dateTimeSubmitted', descending: false)
        .get();

    List<QueryDocumentSnapshot> documents = querySnapshot.docs;
    return documents;
  }

  @override
  Future<void> updateAcceptRequest(String serviceId, String customerId,
      String serviceName, String technicianName) async {
    try {
      // Update service status to "Confirmed"
      final servicesCollection = _firebaseFirestore.collection('services');
      final serviceDoc = servicesCollection.doc(serviceId);
      await serviceDoc.update({'serviceStatus': 'Confirmed'});

      DocumentSnapshot doc =
          await _firebaseFirestore.collection('services').doc(serviceId).get();
      Timestamp assignedDate = doc.get('assignedDate') as Timestamp;
      String assignedTime = doc.get('assignedTime') as String;
      await serviceDoc.update({
        'confirmedDate': assignedDate,
        'confirmedTime': assignedTime,
      });

      await serviceDoc.update({
        'assignedDate': FieldValue.delete(),
        'assignedTime': FieldValue.delete(),
      });
    } catch (e) {
      throw PlatformException(
          code: 'accept-request-failed', message: e.toString());
    }
  }

  @override
  Future<void> updateServiceStatus(
      String id, String newStatus, BuildContext context) async {
    try {
      final servicesCollection = _firebaseFirestore.collection('services');
      final serviceDoc = servicesCollection.doc(id);
      DocumentSnapshot<Map<String, dynamic>> serviceSnapshot =
          await serviceDoc.get();
      await serviceDoc.update({'serviceStatus': newStatus});
    } catch (e) {
      throw PlatformException(
          code: 'update-status-failed', message: e.toString());
    }
  }
}

class MockTechnicianAssigner extends Mock implements TechnicianAssigner {
  late MockDistanceCalculator _disCal;
  late MockDatabase _mockDatabase;
  MockBuildContext? _context;
  GeoPoint? _serviceLocation;
  GeoPoint? _nearestTechnicianLocation;
  String? _nearestTechnicianID;
  List<Map<String, dynamic>> _techniciansMap = [];

  @override
  GeoPoint? get serviceLocation => _serviceLocation;
  @override
  String? get nearestTechnicianID => _nearestTechnicianID;

  MockTechnicianAssigner(MockBuildContext context, MockDatabase mockDatabase) {
    _context = context;
    _disCal = MockDistanceCalculator();
    _mockDatabase = mockDatabase;
  }

  @override
  List<GeoPoint> retrieveTechnicianLocations() {
    return _techniciansMap
        .map((technician) => technician['location'] as GeoPoint)
        .toList();
  }

  @override
  String getNearestTechnicianID() {
    return _techniciansMap.firstWhere(
        (data) => data['location'] == _nearestTechnicianLocation)['id'];
  }

  @override
  Future<String?> pickReassignTechnician(
      String serviceCategory, String city, GeoPoint serviceLocation) async {
    _techniciansMap = await _mockDatabase.getLocationOfAvailableTechnician(
        serviceCategory, city);

    final technicianLocations = retrieveTechnicianLocations();

    if (technicianLocations.length > 1) {
      _nearestTechnicianLocation = _disCal.getNearestTechnicianLocation(
          technicianLocations, serviceLocation);
      _nearestTechnicianID = getNearestTechnicianID();

      return nearestTechnicianID;
    } else if (technicianLocations.length == 1) {
      _nearestTechnicianLocation = technicianLocations.first;
      _nearestTechnicianID = getNearestTechnicianID();

      return nearestTechnicianID;
    }

    return null;
  }
}

class MockTechnicianController extends Mock implements TechnicianController {
  late MockService _service;
  late MockDatabase _mockDatabase;

  MockTechnicianController(MockService mockService, MockDatabase mockDatabase) {
    _service = mockService;
    _mockDatabase = mockDatabase;
  }

  @override
  Future<void> rejectIconPressed(
      QueryDocumentSnapshot serviceDoc, BuildContext context) async {
    String technicianID =
        (serviceDoc.data() as Map<String, dynamic>)["technicianID"];
    final preferredDateTmpStp =
        (serviceDoc.data() as Map<String, dynamic>)["preferredDate"];
    final alternativeDateTmpStp =
        (serviceDoc.data() as Map<String, dynamic>)["alternativeDate"];
    final preferredTime =
        (serviceDoc.data() as Map<String, dynamic>)["preferredTime"];
    final alternativeTime =
        (serviceDoc.data() as Map<String, dynamic>)["alternativeTime"];

    final preferredDate = preferredDateTmpStp.toDate().toLocal();
    final alternativeDate = alternativeDateTmpStp.toDate().toLocal();
    final newPreferredDate =
        DateTime(preferredDate.year, preferredDate.month, preferredDate.day);
    final newAlternativeDate = DateTime(
        alternativeDate.year, alternativeDate.month, alternativeDate.day);

    final serviceName =
        (serviceDoc.data() as Map<String, dynamic>)["serviceName"];
    String serviceCategory = serviceName.split(" - ")[0];
    final city = (serviceDoc.data() as Map<String, dynamic>)["city"];
    final location = (serviceDoc.data() as Map<String, dynamic>)["location"];

    String? technicianFromPreferred;
    String? technicianFromAlternative;

    technicianFromPreferred = await _service.processTechnicianReassign(
        context,
        serviceCategory,
        city,
        location,
        technicianID,
        newPreferredDate,
        preferredTime);

    if (technicianFromPreferred == null || technicianFromPreferred == "") {
      technicianFromAlternative = await _service.processTechnicianReassign(
          context,
          serviceCategory,
          city,
          location,
          technicianID,
          newAlternativeDate,
          alternativeTime);

      if (technicianFromAlternative == null ||
          technicianFromAlternative == "") {
        _mockDatabase.updateCancelledStatus(serviceDoc.id, false, context);
      }
    }

    if (technicianFromPreferred != null && technicianFromPreferred != "") {
      _mockDatabase.updateTechnicianReassigned(serviceDoc.id,
          technicianFromPreferred, newPreferredDate, preferredTime);
    } else if (technicianFromAlternative != null &&
        technicianFromAlternative != "") {
      _mockDatabase.updateTechnicianReassigned(serviceDoc.id,
          technicianFromAlternative, newAlternativeDate, alternativeTime);
    }
  }
}

class MockService extends Mock implements Service {
  late MockDatabase _mockDatabase;
  late MockAuthProvider _mockAuthProvider;
  List<QueryDocumentSnapshot> _servicesDoc = [];

  MockService(MockDatabase mockDatabase, MockAuthProvider mockAuthProvider) {
    _mockDatabase = mockDatabase;
    _mockAuthProvider = mockAuthProvider;
  }

  @override
  Future<List<QueryDocumentSnapshot<Object?>>> retrieveWorkScheduleData(
      BuildContext context) async {
    String id = await _mockAuthProvider.getUserIDFromSP("session_data");
    _servicesDoc = await _mockDatabase.readWorkData(id);

    _servicesDoc.sort((a, b) {
      final String timeA = (a.data() as Map<String, dynamic>)['confirmedTime'];
      final String timeB = (b.data() as Map<String, dynamic>)['confirmedTime'];

      final DateTime dateTimeA =
          DateFormat('h:mma').parse(timeA.split('-')[0].trim());
      final DateTime dateTimeB =
          DateFormat('h:mma').parse(timeB.split('-')[0].trim());

      final String comparableTimeA = DateFormat('HH:mm').format(dateTimeA);
      final String comparableTimeB = DateFormat('HH:mm').format(dateTimeB);

      return comparableTimeA.compareTo(comparableTimeB);
    });
    return _servicesDoc;
  }
}
