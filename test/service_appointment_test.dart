import 'dart:convert';
import 'package:better_home/customer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRootBundle extends Mock implements AssetBundle {}

class MockCustomer extends Mock implements Customer {}

void main() {
  late MockCustomer mockCustomer;
  late MockRootBundle mockRootBundle;

  setUpAll(() {
    mockCustomer = MockCustomer();
    mockRootBundle = MockRootBundle();
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
  });
}
