// ignore_for_file: subtype_of_sealed_class

import 'package:authentication/models/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_data/models/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class MockBuildContext extends Fake implements BuildContext {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockFirebaseFirestore mockFirebaseFirestore;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDatabase mockDatabase;
  late MockQuerySnapshot mockQuerySnapshot;

  setUpAll(() {
    mockFirebaseFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDatabase = MockDatabase(mockFirebaseFirestore);
  });

  group('User profiles', () {
    test('Edit profile (positive input)', () async {
      const id = 'ABC123';
      const name = 'John Doe';
      const email = 'johndoe@gmail.com';
      const city = 'Kuala Lumpur / Selangor';
      const address = '28 Jalan 3/2B, Taman Bukit Anggerik';
      const location = GeoPoint(40.712776, -74.005974);
      const userType = 'technician';

      when(() => mockFirebaseFirestore.collection(any()))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc(any()))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.update(any()))
          .thenAnswer((_) => Future<void>.value());

      await mockDatabase.updateUserProfile(
        id,
        name,
        email,
        city,
        address,
        location,
        userType,
      );

      verify(() => mockFirebaseFirestore.collection('technicians')).called(1);
      verify(() => mockCollectionReference.doc(id)).called(1);
      verify(() => mockDocumentReference.update({
            'name': name,
            'email': email,
            'city': city,
            'address': address,
            'location': location,
          })).called(1);
    });

    test('Edit profile (negative input)', () async {
      const id = 'ABC123';
      const name = 'John Doe';
      const email = 'johndoe@gmail.com';
      const city = 'Kuala Lumpur / Selangor';
      const address = '28 Jalan 3/2B, Taman Bukit Anggerik';
      const location = GeoPoint(40.712776, -74.005974);
      const userType = 'technician';

      when(() => mockFirebaseFirestore.collection(any()))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc(any()))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.update(any())).thenThrow(Exception());

      verify(() => mockFirebaseFirestore.collection('technicians')).called(1);
      verify(() => mockCollectionReference.doc(id)).called(1);
      verify(() => mockDocumentReference.update({
            'name': name,
            'email': email,
            'city': city,
            'address': address,
            'location': location,
          })).called(1);
      expect(
        () async => await mockDatabase.updateUserProfile(
          id,
          name,
          email,
          city,
          address,
          location,
          userType,
        ),
        throwsA(isA<PlatformException>().having(
          (e) => e.code,
          'code',
          'update-profile-failed',
        )),
      );
    });

    test('Retrieve technician’s review (matching review found)', () async {
      const technicianID = 'ABC123';

      final serviceDoc1 = MockQueryDocumentSnapshot();
      final serviceDoc2 = MockQueryDocumentSnapshot();
      final serviceDocs = [serviceDoc1, serviceDoc2];

      final ratingsDoc1 = MockDocumentSnapshot();
      final ratingsDoc2 = MockDocumentSnapshot();
      final ratingsDocs = [ratingsDoc1, ratingsDoc2];

      final servicesQueryMock = MockQuery();
      final serviceStatusQueryMock = MockQuery();

      when(() => mockFirebaseFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.where('technicianID',
          isEqualTo: technicianID)).thenReturn(servicesQueryMock);
      when(() => servicesQueryMock.where('serviceStatus', isEqualTo: 'Rated'))
          .thenReturn(serviceStatusQueryMock);
      when(() => serviceStatusQueryMock.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn(serviceDocs);
      when(() => serviceDoc1.id).thenReturn('serviceDoc1');
      when(() => serviceDoc2.id).thenReturn('serviceDoc2');
      when(() => mockFirebaseFirestore.collection('ratings'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.doc(any()))
          .thenReturn(mockDocumentReference);
      when(() => mockDocumentReference.get()).thenAnswer((_) async {
        final result = ratingsDocs.removeAt(0);
        return Future.value(result);
      });
      when(() => ratingsDoc1.exists).thenReturn(true);
      when(() => ratingsDoc2.exists).thenReturn(true);

      final result = await mockDatabase.readReviewsForTechnician(technicianID);

      verify(() => mockFirebaseFirestore.collection('services')).called(1);
      verify(() => mockCollectionReference.where('technicianID',
          isEqualTo: technicianID)).called(1);
      verify(() => servicesQueryMock.where('serviceStatus', isEqualTo: 'Rated'))
          .called(1);
      verify(() => mockFirebaseFirestore.collection('ratings')).called(2);
      verify(() => mockCollectionReference.doc(serviceDoc1.id)).called(1);
      verify(() => mockCollectionReference.doc(serviceDoc2.id)).called(1);
      expect(result, isA<List<Map<String, dynamic>?>>());
      expect(result.length, equals(2));
    });

    test('Retrieve technician’s review (no matching review found)', () async {
      const technicianID = 'DEF456';

      final servicesQueryMock = MockQuery();
      final serviceStatusQueryMock = MockQuery();

      when(() => mockFirebaseFirestore.collection('services'))
          .thenReturn(mockCollectionReference);
      when(() => mockCollectionReference.where('technicianID',
          isEqualTo: technicianID)).thenReturn(servicesQueryMock);
      when(() => servicesQueryMock.where('serviceStatus', isEqualTo: 'Rated'))
          .thenReturn(serviceStatusQueryMock);
      when(() => serviceStatusQueryMock.get())
          .thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([]);
      when(() => mockFirebaseFirestore.collection('ratings'))
          .thenReturn(mockCollectionReference);

      final result = await mockDatabase.readReviewsForTechnician(technicianID);

      verify(() => mockFirebaseFirestore.collection('services')).called(1);
      verify(() => mockCollectionReference.where('technicianID',
          isEqualTo: technicianID)).called(1);
      verify(() => servicesQueryMock.where('serviceStatus', isEqualTo: 'Rated'))
          .called(1);
      verifyNever(() => mockFirebaseFirestore.collection('ratings'));
      expect(result, isEmpty);
    });
  });
}

class MockDatabase extends Mock implements Database {
  final MockFirebaseFirestore _firebaseFirestore;

  MockDatabase(this._firebaseFirestore);

  @override
  Future<void> updateUserProfile(
      String id,
      String name,
      String email,
      String? city,
      String? address,
      GeoPoint? location,
      String userType) async {
    try {
      final collectionName =
          userType == 'customer' ? 'customers' : 'technicians';
      final userCollection = _firebaseFirestore.collection(collectionName);
      final userDoc = userCollection.doc(id);

      if (userType == "customer") {
        await userDoc.update({'name': name, 'email': email});
      } else {
        await userDoc.update({
          'name': name,
          'email': email,
          'city': city,
          'address': address,
          'location': location
        });
      }
    } catch (e) {
      throw PlatformException(
          code: 'update-profile-failed', message: e.toString());
    }
  }

  @override
  Future<List<Map<String, dynamic>?>> readReviewsForTechnician(
      String technicianID) async {
    final QuerySnapshot<Map<String, dynamic>> servicesSnapshot =
        await _firebaseFirestore
            .collection('services')
            .where('technicianID', isEqualTo: technicianID)
            .where('serviceStatus', isEqualTo: "Rated")
            .get();

    if (servicesSnapshot.docs.isEmpty) {
      return [];
    }

    final List<Map<String, dynamic>?> ratingsData = [];
    for (final DocumentSnapshot<Map<String, dynamic>> serviceDoc
        in servicesSnapshot.docs) {
      final String serviceDocID = serviceDoc.id;
      final DocumentSnapshot<Map<String, dynamic>> ratingsSnapshot =
          await _firebaseFirestore
              .collection('ratings')
              .doc(serviceDocID)
              .get();

      if (ratingsSnapshot.exists) {
        ratingsData.add(ratingsSnapshot.data());
      }
    }

    return ratingsData;
  }
}
