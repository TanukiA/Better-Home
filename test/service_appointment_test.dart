import 'package:better_home/customer.dart';
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

class MockDatabase extends Mock implements Database {}

class MockCustomer extends Mock implements Customer {}

class MockStripe extends Mock implements Stripe {}

class MockPayment extends Mock implements Payment {}

class MockServiceRequestFormProvider extends Mock
    implements ServiceRequestFormProvider {}

void main() {
  late MockDatabase mockDatabase;
  late MockCustomerController mockCustomerController;
  late MockServiceController mockServiceController;
  late MockPayment mockPayment;
  late MockStripe mockStripe;
  late DistanceCalculator distanceCalculator;

  setUpAll(() {
    mockDatabase = MockDatabase();
    mockCustomerController = MockCustomerController(mockDatabase);
    mockServiceController = MockServiceController();
    mockStripe = MockStripe();
    mockPayment = MockPayment();
    distanceCalculator = DistanceCalculator();
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
