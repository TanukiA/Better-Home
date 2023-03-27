import 'package:map/controllers/location_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:better_home/utils.dart';
import 'package:flutter/material.dart';

typedef DisplayPredictionCallback = void Function(
  Prediction prediction,
  ScaffoldState? scaffoldState,
);

class MapService extends ModelMVC {
  static const _kGoogleApiKey = 'AIzaSyBSn1Cv_zs3ZWtal9VMhnbVaO4q-9LTkB4';
  final Mode _mode = Mode.overlay;

  final LocationController _locationCon;

  MapService(this._locationCon);

  String get kGoogleApiKey => _kGoogleApiKey;

  Future<void> handleSearchButton(
      BuildContext context,
      GlobalKey<ScaffoldState> homeScaffoldKey,
      DisplayPredictionCallback displayPredictionCallback) async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: (response) => handleError(response, context),
        mode: _mode,
        language: 'en',
        strictbounds: false,
        types: [""],
        decoration: InputDecoration(
            hintText: 'Search',
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white))),
        components: [Component(Component.country, "my")]);

    displayPredictionCallback(p!, homeScaffoldKey.currentState);
  }

  void handleError(PlacesAutocompleteResponse response, BuildContext context) {
    showSnackBar(context, response.errorMessage!);
  }
/*
  Future<void> displayPrediction(Prediction p, ScaffoldState? currentState,
      Set<Marker> markersList, GoogleMapController googleMapController) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: kGoogleApiKey,
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    final lat = detail.result.geometry!.location.lat;
    final lng = detail.result.geometry!.location.lng;
    _locationCon.setLat = lat;
    _locationCon.setLng = lng;
    _locationCon.setAddress = p.description!;

    markersList.clear();
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.0));
  }*/
}
