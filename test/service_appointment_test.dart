// ignore_for_file: subtype_of_sealed_class

import 'package:better_home/customer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:map/models/distance_calculator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_data/models/database.dart';
import 'package:service/controllers/customer_controller.dart';
import 'package:service/controllers/service_controller.dart';
import 'package:service/models/payment.dart';
import 'package:service/models/service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:service/models/service_request_form_provider.dart';
import 'package:image_picker/image_picker.dart';

class MockCustomer extends Mock implements Customer {}

class MockStripe extends Mock implements Stripe {}

class MockPayment extends Mock implements Payment {}

class MockServiceRequestFormProvider extends Mock
    implements ServiceRequestFormProvider {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockBuildContext extends Fake implements BuildContext {}

void main() {
  late MockDatabase mockDatabase;
  late MockCustomerController mockCustomerController;
  late MockServiceController mockServiceController;
  late MockPayment mockPayment;
  late MockStripe mockStripe;
  late DistanceCalculator distanceCalculator;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollectionRef;
  late MockDocumentReference mockDocumentRef;
  late MockBuildContext mockBuildContext;

  setUpAll(() {
    mockServiceController = MockServiceController();
    mockStripe = MockStripe();
    mockPayment = MockPayment();
    distanceCalculator = DistanceCalculator();
    mockFirestore = MockFirebaseFirestore();
    mockCollectionRef = MockCollectionReference();
    mockDocumentRef = MockDocumentReference();
    mockDatabase = MockDatabase(mockFirestore);
    mockCustomerController = MockCustomerController(mockDatabase);
    mockBuildContext = MockBuildContext();

    registerFallbackValue(MockBuildContext());
  });

  group('Service Appointment', () {
    test('Check technician availability for the selected appointment date',
        () async {
      const serviceCategory = 'Electrical & Wiring';
      const city = 'Putrajaya';
      final date = DateTime(2023, 8, 25, 10, 30);
      const matchedQty = 6;

      final expectedAvailability = [true, false, true, false];

      when(() => mockDatabase.getTechnicianQtyMatched(serviceCategory, city))
          .thenAnswer((_) async => matchedQty);

      when(
          () => mockCustomerController.mockedCus.retrieveTechnicianAvailability(
                serviceCategory,
                city,
                any(),
                matchedQty,
                any(),
              )).thenAnswer((_) async => expectedAvailability);

      final result =
          await mockCustomerController.retrieveTechnicianAvailability(
        serviceCategory,
        city,
        date,
      );

      expect(result, expectedAvailability);
    });

    test('Validate service request input (positive input)', () async {
      final mockProvider = MockServiceRequestFormProvider();

      when(() => mockProvider.city).thenReturn('Melaka');
      when(() => mockProvider.address).thenReturn('Example Address');
      when(() => mockProvider.lat).thenReturn(2.330100714481708);
      when(() => mockProvider.lng).thenReturn(102.24918716249788);
      when(() => mockProvider.preferredDate)
          .thenReturn(DateTime(2023, 8, 28, 10, 30));
      when(() => mockProvider.preferredTimeSlot).thenReturn('3:00PM - 5:00PM');
      when(() => mockProvider.alternativeDate)
          .thenReturn(DateTime(2023, 8, 25, 10, 30));
      when(() => mockProvider.alternativeTimeSlot)
          .thenReturn('3:00PM - 5:00PM');
      when(() => mockProvider.variation)
          .thenReturn('Light fixture replacement');
      when(() => mockProvider.description)
          .thenReturn('Replace pendant light in living room.');
      when(() => mockProvider.propertyType).thenReturn('Flat/Apartment');

      final result =
          mockServiceController.validateServiceRequestInput(mockProvider);

      expect(result, true);
    });

    test(
        'Validate service request input (negative input - invalid preferred and alternative appointment date time)',
        () async {
      final mockProvider = MockServiceRequestFormProvider();

      when(() => mockProvider.city).thenReturn('Melaka');
      when(() => mockProvider.address).thenReturn('Example Address');
      when(() => mockProvider.lat).thenReturn(2.330100714481708);
      when(() => mockProvider.lng).thenReturn(102.24918716249788);
      when(() => mockProvider.preferredDate)
          .thenReturn(DateTime(2023, 8, 25, 10, 30));
      when(() => mockProvider.preferredTimeSlot).thenReturn('3:00PM - 5:00PM');
      when(() => mockProvider.alternativeDate)
          .thenReturn(DateTime(2023, 8, 25, 10, 30));
      when(() => mockProvider.alternativeTimeSlot)
          .thenReturn('3:00PM - 5:00PM');
      when(() => mockProvider.variation)
          .thenReturn('Light fixture replacement');
      when(() => mockProvider.description)
          .thenReturn('Replace pendant light in living room.');
      when(() => mockProvider.propertyType).thenReturn('Flat/Apartment');

      final result =
          mockServiceController.validateServiceRequestInput(mockProvider);

      expect(result, false);
    });

    test('Stripe payment succeed', () async {
      MockService.updatePaymentSuccess(false);
      when(() => mockStripe.presentPaymentSheet())
          .thenAnswer((_) => Future.value());

      when(() => mockPayment.makePayment()).thenAnswer((_) async {
        try {
          await mockStripe.presentPaymentSheet().then((paymentResult) {
            MockService.updatePaymentSuccess(true);
          });
        } on StripeException catch (e) {
          fail(e.toString());
        } catch (e) {
          fail(e.toString());
        }
      });

      await mockPayment.makePayment();

      expect(MockService.paymentSuccess, isTrue);
    });

    test('Stripe payment failed', () async {
      MockService.updatePaymentSuccess(false);
      when(() => mockStripe.presentPaymentSheet()).thenAnswer((_) {
        throw Exception('Payment failed');
      });

      bool exceptionCaught = false;

      when(() => mockPayment.makePayment()).thenAnswer((_) async {
        try {
          await mockStripe.presentPaymentSheet().then((paymentResult) {
            MockService.updatePaymentSuccess(true);
          });
        } on StripeException catch (e) {
          exceptionCaught = true;
        } catch (e) {
          exceptionCaught = true;
        }
      });

      await mockPayment.makePayment();

      expect(exceptionCaught, isTrue);
      expect(MockService.paymentSuccess, isFalse);
    });

    test('Calculate to get nearest technician location', () {
      final technicianLocations = [
        const GeoPoint(40.7128, 74.0060),
        const GeoPoint(34.0522, 118.2437),
        const GeoPoint(41.8781, 87.6298),
      ];
      const serviceLocation = GeoPoint(37.7749, 122.4194);

      final nearestLocation = distanceCalculator.getNearestTechnicianLocation(
        technicianLocations,
        serviceLocation,
      );

      expect(nearestLocation, technicianLocations[1]);
    });

    test('Submit service request data', () async {
      final data = {
        'dateTimeSubmitted': DateTime.now(),
        'serviceStatus': 'Assigning',
        'customerID': 'ABC123',
        'technicianID': 'DEF456',
        'address': 'Example Address',
        'location': const GeoPoint(2.330100714481708, 102.24918716249788),
        'city': 'Melaka',
        'paidAmount': 120.0,
        'serviceName':
            'Electrical & Wiring - Light Fixture/Ceiling Fan Install',
        'serviceVariation': 'Light fixture replacement',
        'propertyType': 'Flat/Apartment',
        'description': 'Replace pendant light in living room.',
        'preferredDate': DateTime(2023, 8, 28, 10, 30),
        'preferredTime': '3:00PM - 5:00PM',
        'alternativeDate': DateTime(2023, 8, 25, 10, 30),
        'alternativeTime': '3:00PM - 5:00PM',
        'assignedDate': DateTime(2023, 8, 28, 10, 30),
        'assignedTime': '3:00PM - 5:00PM',
      };
      final imgFiles = [
        XFile('path/to/image1.png'),
        XFile('path/to/image2.png')
      ];

      when(() => mockFirestore.collection('services'))
          .thenReturn(mockCollectionRef);
      when(() => mockCollectionRef.add(data))
          .thenAnswer((_) async => mockDocumentRef);
      when(() => mockDocumentRef.id).thenReturn('serviceId');
      when(() => mockDatabase.uploadServiceImages(mockDocumentRef, imgFiles))
          .thenAnswer((_) async => ['image1-url', 'image2-url']);
      when(() => mockDocumentRef.update({
            'images': ['image1-url', 'image2-url']
          })).thenAnswer((_) async => Future<void>);

      await mockDatabase.storeServiceRequest(data, imgFiles, mockBuildContext);

      verify(() => mockFirestore.collection('services')).called(1);
      verify(() => mockCollectionRef.add(data)).called(1);
      verify(() => mockDatabase.uploadServiceImages(mockDocumentRef, imgFiles))
          .called(1);
      verify(() => mockDocumentRef.update({
            'images': ['image1-url', 'image2-url']
          })).called(1);
    });
  });
}

class MockService extends Mock implements Service {
  static bool paymentSuccess = false;

  static void updatePaymentSuccess(bool newValue) {
    paymentSuccess = newValue;
  }
}

class MockCustomerController extends Mock implements CustomerController {
  late MockCustomer _mockedCus;
  late MockDatabase _mockedDatabase;

  MockCustomer get mockedCus => _mockedCus;

  MockCustomerController(MockDatabase mockDatabase) {
    _mockedCus = MockCustomer();
    _mockedDatabase = mockDatabase;
  }

  @override
  Future<List<bool>> retrieveTechnicianAvailability(
      String serviceCategory, String city, DateTime date) async {
    int matchedQty =
        await _mockedDatabase.getTechnicianQtyMatched(serviceCategory, city);

    if (matchedQty == 0) {
      Future<List<bool>> result = Future.value([false, false, false, false]);

      return result;
    } else {
      final newDate = DateTime(date.year, date.month, date.day);

      List<String> timeSlotList = [
        '10:00AM - 12:00PM',
        '1:00PM - 3:00PM',
        '3:00PM - 5:00PM',
        '5:00PM - 7:00PM'
      ];

      final result = await mockedCus.retrieveTechnicianAvailability(
          serviceCategory, city, newDate, matchedQty, timeSlotList);

      return result;
    }
  }
}

class MockServiceController extends Mock implements ServiceController {
  @override
  bool validDateAndTime(DateTime? preferredDate, String? preferredTimeSlot,
      DateTime? alternativeDate, String? alternativeTimeSlot) {
    if (preferredDate == null ||
        preferredTimeSlot == null ||
        alternativeDate == null ||
        alternativeTimeSlot == null) {
      return true;
    }

    if ((preferredDate == alternativeDate) &&
        (preferredTimeSlot == alternativeTimeSlot)) {
      return false;
    }

    return true;
  }

  @override
  bool validateServiceRequestInput(ServiceRequestFormProvider provider) {
    if (provider.city == null || provider.city!.isEmpty) {
      return false;
    }
    if (provider.address == null || provider.address!.isEmpty) {
      return false;
    }
    if (provider.lat == null) {
      return false;
    }
    if (provider.lng == null) {
      return false;
    }
    if (provider.preferredDate == null) {
      return false;
    }
    if (provider.preferredTimeSlot == null ||
        provider.preferredTimeSlot!.isEmpty) {
      return false;
    }
    if (provider.alternativeDate == null) {
      return false;
    }
    if (provider.alternativeTimeSlot == null ||
        provider.alternativeTimeSlot!.isEmpty) {
      return false;
    }
    if (provider.variation == null || provider.variation!.isEmpty) {
      return false;
    }
    if (provider.description == null || provider.description!.isEmpty) {
      return false;
    }
    if (provider.propertyType == null || provider.propertyType!.isEmpty) {
      return false;
    }

    if (!validDateAndTime(provider.preferredDate, provider.preferredTimeSlot,
        provider.alternativeDate, provider.alternativeTimeSlot)) {
      return false;
    }
    return true;
  }
}

class MockDatabase extends Mock implements Database {
  final MockFirebaseFirestore _firebaseFirestore;

  MockDatabase(this._firebaseFirestore);

  @override
  Future<void> storeServiceRequest(Map<String, dynamic> data,
      List<XFile>? imgFiles, BuildContext context) async {
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
}
