import 'dart:convert';
import 'package:better_home/customer.dart';
import 'package:flutter/material.dart';
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

class MockRootBundle extends Mock implements AssetBundle {}

class MockDatabase extends Mock implements Database {}

class MockCustomer extends Mock implements Customer {}

class MockStripe extends Mock implements Stripe {}

class MockPayment extends Mock implements Payment {}

class MockServiceRequestFormProvider extends Mock
    implements ServiceRequestFormProvider {}

void main() {
  late MockCustomer mockCustomer;
  late MockRootBundle mockRootBundle;
  late MockDatabase mockDatabase;
  late MockCustomerController mockCustomerController;
  late MockServiceController mockServiceController;
  late MockPayment mockPayment;
  late MockStripe mockStripe;
  late DistanceCalculator distanceCalculator;

  setUpAll(() {
    mockCustomer = MockCustomer();
    mockRootBundle = MockRootBundle();
    mockDatabase = MockDatabase();
    mockCustomerController = MockCustomerController(mockDatabase);
    mockServiceController = MockServiceController();
    mockStripe = MockStripe();
    mockPayment = MockPayment();
    distanceCalculator = DistanceCalculator();
  });

  group('Service Apointment', () {
    test('Load service description', () async {
      const serviceTitle = 'Plumbing - Leakage Repair';
      const jsonString = '''
    {
      "Plumbing - Leakage Repair": {
        "explanations": [
          "Leaky pipes",
          "Damaged / cracked pipes",
          "Dripping taps",
          "Noisy taps"
        ],
        "priceRange": "RM 100 - 140",
        "img": "assets/leakage_repair_img.jpeg"
      },
      "Plumbing - Drainage Service": {
        "explanations": [
          "Clogged drains",
          "Blocked sewer lines",
          "Slow draining sinks",
          "Drain cleaning / maintenance"
        ],
        "priceRange": "RM 50 - 80",
        "img": "assets/drainage_img.jpg"
      },
      "Plumbing - Water Heater Repair / Install": {
        "explanations": [
          "New installation",
          "Replacing existing water heater",
          "Thermostat repair and replacement"
        ],
        "priceRange": "RM 110 - 300",
        "img": "assets/water_heater_repair.jpg"
      }
    }
  ''';

      when(() => mockRootBundle.loadString(any()))
          .thenAnswer((_) async => jsonString);

      when(() => mockCustomer.loadServiceDescription(serviceTitle))
          .thenAnswer((_) async {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        return data[serviceTitle] as Map<String, dynamic>;
      });

      final serviceDescription =
          await mockCustomer.loadServiceDescription(serviceTitle);

      expect(serviceDescription, {
        "explanations": [
          "Leaky pipes",
          "Damaged / cracked pipes",
          "Dripping taps",
          "Noisy taps"
        ],
        "priceRange": "RM 100 - 140",
        "img": "assets/leakage_repair_img.jpeg"
      });
    });

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

      when(() =>
              mockServiceController.validateServiceRequestInput(mockProvider))
          .thenAnswer((_) {
        if (mockProvider.city == null || mockProvider.city!.isEmpty) {
          return false;
        }
        if (mockProvider.address == null || mockProvider.address!.isEmpty) {
          return false;
        }
        if (mockProvider.lat == null) {
          return false;
        }
        if (mockProvider.lng == null) {
          return false;
        }
        if (mockProvider.preferredDate == null) {
          return false;
        }
        if (mockProvider.preferredTimeSlot == null ||
            mockProvider.preferredTimeSlot!.isEmpty) {
          return false;
        }
        if (mockProvider.alternativeDate == null) {
          return false;
        }
        if (mockProvider.alternativeTimeSlot == null ||
            mockProvider.alternativeTimeSlot!.isEmpty) {
          return false;
        }
        if (mockProvider.variation == null || mockProvider.variation!.isEmpty) {
          return false;
        }
        if (mockProvider.description == null ||
            mockProvider.description!.isEmpty) {
          return false;
        }
        if (mockProvider.propertyType == null ||
            mockProvider.propertyType!.isEmpty) {
          return false;
        }

        if (!mockServiceController.validDateAndTime(
            mockProvider.preferredDate,
            mockProvider.preferredTimeSlot,
            mockProvider.alternativeDate,
            mockProvider.alternativeTimeSlot)) {
          return false;
        }
        return true;
      });

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

      when(() =>
              mockServiceController.validateServiceRequestInput(mockProvider))
          .thenAnswer((_) {
        if (mockProvider.city == null || mockProvider.city!.isEmpty) {
          return false;
        }
        if (mockProvider.address == null || mockProvider.address!.isEmpty) {
          return false;
        }
        if (mockProvider.lat == null) {
          return false;
        }
        if (mockProvider.lng == null) {
          return false;
        }
        if (mockProvider.preferredDate == null) {
          return false;
        }
        if (mockProvider.preferredTimeSlot == null ||
            mockProvider.preferredTimeSlot!.isEmpty) {
          return false;
        }
        if (mockProvider.alternativeDate == null) {
          return false;
        }
        if (mockProvider.alternativeTimeSlot == null ||
            mockProvider.alternativeTimeSlot!.isEmpty) {
          return false;
        }
        if (mockProvider.variation == null || mockProvider.variation!.isEmpty) {
          return false;
        }
        if (mockProvider.description == null ||
            mockProvider.description!.isEmpty) {
          return false;
        }
        if (mockProvider.propertyType == null ||
            mockProvider.propertyType!.isEmpty) {
          return false;
        }

        if (!mockServiceController.validDateAndTime(
            mockProvider.preferredDate,
            mockProvider.preferredTimeSlot,
            mockProvider.alternativeDate,
            mockProvider.alternativeTimeSlot)) {
          return false;
        }
        return true;
      });

      final result =
          mockServiceController.validateServiceRequestInput(mockProvider);

      expect(result, false);
    });

    test('Stripe payment succeed', () async {
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
}
