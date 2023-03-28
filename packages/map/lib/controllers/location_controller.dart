import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/models/map_service.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_db/models/database.dart';
import 'package:better_home/utils.dart';

class LocationController extends ControllerMVC {
  late MapService _map;
  late Firestore _db;

  MapService get map => _map;
  LocationController() {
    _map = MapService(this);
  }

  Future<void> handleSearchButton(
      BuildContext context,
      GlobalKey<ScaffoldState> homeScaffoldKey,
      DisplayPredictionCallback displayPredictionCallback) {
    return _map.handleSearchButton(
        context, homeScaffoldKey, displayPredictionCallback);
  }

  Future<void> handleConfirmButton(BuildContext context,
      String? selectedAddress, double? lat, double? lng) async {
    if (selectedAddress != null && lat != null && lng != null) {
      Navigator.of(context).pop({
        'address': selectedAddress,
        'latitude': lat,
        'longitude': lng,
      });
    } else {
      showSnackBar(context, 'Please select an address');
    }
  }

  String getApiKey() {
    return _map.kGoogleApiKey;
  }
}
