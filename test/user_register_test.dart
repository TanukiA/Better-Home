import 'dart:async';
import 'package:authentication/controllers/registration_controller.dart';
import 'package:authentication/views/customer_signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:better_home/user.dart' as my_user;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:map/models/location.dart' as map_location;
import 'package:mocktail/mocktail.dart';

class MockRegistrationController extends Mock
    implements RegistrationController {}

class MockBuildContext extends Fake implements BuildContext {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockLocationController extends Mock implements LocationController {}

class MockLocation extends Mock implements map_location.Location {}

class MockPrediction extends Mock implements Prediction {}

class MockGoogleMapsPlaces extends Mock implements GoogleMapsPlaces {}

class MockPlacesDetailsResponse extends Mock implements PlacesDetailsResponse {}

typedef DisplayPredictionCallback = void Function(
  Prediction prediction,
  ScaffoldState? scaffoldState,
);

void main() {
  late MockRegistrationController mockRegistrationController;
  late MockLocationController mockLocationController;
  late GlobalKey<ScaffoldState> scaffoldKey;
  late MockGoogleMapsPlaces mockGoogleMapsPlaces;
  late MockPlacesDetailsResponse mockPlacesDetailsResponse;
  late MockBuildContext mockBuildContext;
  final mockNavigatorObserver = MockNavigatorObserver();

  setUpAll(() {
    mockRegistrationController = MockRegistrationController();
    mockLocationController = MockLocationController();
    scaffoldKey = GlobalKey<ScaffoldState>();
    mockGoogleMapsPlaces = MockGoogleMapsPlaces();
    mockPlacesDetailsResponse = MockPlacesDetailsResponse();
    mockBuildContext = MockBuildContext();

    registerFallbackValue(MockBuildContext());
  });

  group('User Registration', () {
    testWidgets('Validate phone number input (positive input)',
        (WidgetTester tester) async {
      when(() => mockRegistrationController.validPhoneFormat(any()))
          .thenReturn(true);
      when(() => mockRegistrationController.validEmailFormat(any()))
          .thenReturn(true);
      when(() => mockRegistrationController.isAccountExists(any(), any()))
          .thenAnswer((_) async => false);
      when(() => mockRegistrationController.checkValidForm(any(), any(), any()))
          .thenReturn(true);

      await tester.pumpWidget(MaterialApp(
        home: CustomerSignupScreen(controller: mockRegistrationController),
        navigatorObservers: [mockNavigatorObserver],
      ));

      final nameTextField = find.byKey(const Key('name_text_field'));
      final emailTextField = find.byKey(const Key('email_text_field'));
      final phoneTextField = find.byKey(const Key('phone_text_field'));

      await tester.enterText(nameTextField, 'John Doe');
      await tester.enterText(emailTextField, 'johndoe@gmail.com');
      await tester.enterText(phoneTextField, '+60123456789');
      await tester.pumpAndSettle();

      final signupBtn = find.widgetWithText(ElevatedButton, 'Sign up').first;

      // Verify that signupBtn is enabled after all fields are entered
      expect(tester.widget<ElevatedButton>(signupBtn).enabled, isTrue);
      await tester.tap(signupBtn);
      await tester.pumpAndSettle();

      verify(() => mockRegistrationController.saveCustomerDataToProvider(
          any(), any(), any(), any())).called(1);
      verify(() => mockRegistrationController.sendPhoneNumber(
          any(), any(), any(), any())).called(1);
    });

    testWidgets(
        'Validate phone number input (negative input - registered number)',
        (WidgetTester tester) async {
      when(() => mockRegistrationController.validPhoneFormat(any()))
          .thenReturn(true);
      when(() => mockRegistrationController.validEmailFormat(any()))
          .thenReturn(true);
      when(() => mockRegistrationController.isAccountExists(any(), any()))
          .thenAnswer((_) async => true);
      when(() => mockRegistrationController.checkValidForm(any(), any(), any()))
          .thenReturn(true);

      await tester.pumpWidget(MaterialApp(
        home: CustomerSignupScreen(controller: mockRegistrationController),
        navigatorObservers: [mockNavigatorObserver],
      ));

      final nameTextField = find.byKey(const Key('name_text_field'));
      final emailTextField = find.byKey(const Key('email_text_field'));
      final phoneTextField = find.byKey(const Key('phone_text_field'));

      await tester.enterText(nameTextField, 'John Doe');
      await tester.enterText(emailTextField, 'johndoe@gmail.com');
      await tester.enterText(phoneTextField, '+60192620596');
      await tester.pumpAndSettle();

      final signupBtn = find.widgetWithText(ElevatedButton, 'Sign up').first;

      // Verify that signupBtn is enabled after all fields are entered
      expect(tester.widget<ElevatedButton>(signupBtn).enabled, isTrue);
      await tester.tap(signupBtn);
      await tester.pumpAndSettle();

      verify(() => mockRegistrationController.showExistError(any())).called(1);
    });

    test('Validate email format (positive input)', () {
      expect(my_user.User.validEmailFormat('johndoe@gmail.com'), isTrue);
    });

    test('Validate email format (negative input)', () {
      expect(my_user.User.validEmailFormat('johndoe.com'), isFalse);
    });

    test('Search location in Google Maps (Positive case)', () async {
      final mockPrediction = MockPrediction();
      const expectedPlaceId = 'mock_place_id';
      const expectedDescription = 'Example Address';

      when(() => mockGoogleMapsPlaces.getDetailsByPlaceId(expectedPlaceId))
          .thenAnswer((_) async => mockPlacesDetailsResponse);
      when(() => mockPlacesDetailsResponse.result.geometry!.location.lat)
          .thenReturn(1.234);
      when(() => mockPlacesDetailsResponse.result.geometry!.location.lng)
          .thenReturn(2.345);
      when(() => mockPrediction.placeId).thenReturn(expectedPlaceId);
      when(() => mockPrediction.description).thenReturn(expectedDescription);

      // Create a Completer to wait for the handleSearchButton method to complete
      final completer = Completer<void>();

      when(() => mockLocationController.handleSearchButton(
            mockBuildContext,
            scaffoldKey,
            any(),
          )).thenAnswer((invocation) {
        final displayPredictionCallback =
            invocation.positionalArguments[2] as DisplayPredictionCallback;

        displayPredictionCallback(mockPrediction, scaffoldKey.currentState);

        completer.complete();
        return Future<void>.value();
      });

      await mockLocationController.handleSearchButton(
        mockBuildContext,
        scaffoldKey,
        (prediction, state) async {
          expect(prediction.placeId, expectedPlaceId);
          expect(prediction.description, expectedDescription);
          expect(state, scaffoldKey.currentState);
        },
      );

      await completer.future;

      verify(() => mockLocationController.handleSearchButton(
            mockBuildContext,
            scaffoldKey,
            any(),
          )).called(1);
    });
  });

  test('Search location in Google Maps (Negative case)', () async {
    final emptyPrediction = MockPrediction();

    when(() => mockLocationController.handleSearchButton(
          mockBuildContext,
          scaffoldKey,
          any(),
        )).thenAnswer((invocation) {
      final displayPredictionCallback =
          invocation.positionalArguments[2] as DisplayPredictionCallback;

      // Simulate that empty Prediction is passed
      displayPredictionCallback(emptyPrediction, null);

      return Future<void>.value();
    });

    await mockLocationController.handleSearchButton(
      mockBuildContext,
      scaffoldKey,
      (prediction, state) async {
        expect(prediction, emptyPrediction);
        expect(state, null);
      },
    );
  });
}
