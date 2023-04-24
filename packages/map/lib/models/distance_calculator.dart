import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' show cos, sqrt, asin;

class DistanceCalculator extends ModelMVC {
// Haversine formula used to calculate distance between two GeoPoints
  double calculateDistance(GeoPoint point1, GeoPoint point2) {
    final lat1 = point1.latitude;
    final lng1 = point1.longitude;
    final lat2 = point2.latitude;
    final lng2 = point2.longitude;

    const p = 0.017453292519943295;
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lng2 - lng1) * p)) / 2;

    return 12742 * asin(sqrt(a));
  }

  GeoPoint getNearestTechnicianLocation(
      List<GeoPoint> technicianLocations, GeoPoint serviceLocation) {
    double shortestDistance = double.infinity;
    GeoPoint nearestLocation = technicianLocations[0];

    for (final location in technicianLocations) {
      final currentDistance = calculateDistance(location, serviceLocation);
      if (currentDistance < shortestDistance) {
        shortestDistance = currentDistance;
        nearestLocation = location;
      }
    }

    return nearestLocation;
  }
}
