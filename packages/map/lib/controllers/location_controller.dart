import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map/models/map_service.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:firebase_db/models/database.dart';

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

  String getApiKey() {
    return _map.kGoogleApiKey;
  }
}
