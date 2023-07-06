import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_data/models/database.dart';
import 'package:flutter/material.dart';
import 'package:map/models/distance_calculator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:service/models/service_request_form_provider.dart';

class TechnicianAssigner extends ModelMVC {
  late DistanceCalculator _disCal;
  BuildContext? _context;
  GeoPoint? _serviceLocation;
  GeoPoint? _nearestTechnicianLocation;
  String? _nearestTechnicianID;
  List<Map<String, dynamic>> _techniciansMap = [];

  GeoPoint? get serviceLocation => _serviceLocation;
  String? get nearestTechnicianID => _nearestTechnicianID;

  TechnicianAssigner(BuildContext context) {
    _context = context;
    _disCal = DistanceCalculator();
  }

  Future<void> pickSuitableTechnician() async {
    Database firestore = Database();
    final provider =
        Provider.of<ServiceRequestFormProvider>(_context!, listen: false);
    _techniciansMap = await firestore.getLocationOfAvailableTechnician(
        provider.serviceCategory!, provider.city!);
    convertServiceLocationToGeoPoint(provider.lat!, provider.lng!);

    final technicianLocations = retrieveTechnicianLocations();
    // if there is more than one technician's location, pick the nearest technician
    // is there is one technician's location  only, directly assign him
    if (technicianLocations.length > 1) {
      _nearestTechnicianLocation = _disCal.getNearestTechnicianLocation(
          technicianLocations, _serviceLocation!);
    } else {
      _nearestTechnicianLocation = technicianLocations.first;
    }

    _nearestTechnicianID = getNearestTechnicianID();
  }

  List<GeoPoint> retrieveTechnicianLocations() {
    return _techniciansMap
        .map((technician) => technician['location'] as GeoPoint)
        .toList();
  }

  void convertServiceLocationToGeoPoint(double lat, double lng) {
    LatLng location = LatLng(lat, lng);
    _serviceLocation = GeoPoint(location.latitude, location.longitude);
  }

  String getNearestTechnicianID() {
    return _techniciansMap.firstWhere(
        (data) => data['location'] == _nearestTechnicianLocation)['id'];
  }

  Future<String?> pickReassignTechnician(
      String serviceCategory, String city, GeoPoint serviceLocation) async {
    Database firestore = Database();
    _techniciansMap =
        await firestore.getLocationOfAvailableTechnician(serviceCategory, city);

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
