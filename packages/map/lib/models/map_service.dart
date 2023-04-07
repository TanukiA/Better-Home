import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:better_home/utils.dart';
import 'package:flutter/material.dart';

typedef DisplayPredictionCallback = void Function(
  Prediction prediction,
  ScaffoldState? scaffoldState,
);

class MapService extends ModelMVC {
  static const _kGoogleApiKey = 'AIzaSyBSn1Cv_zs3ZWtal9VMhnbVaO4q-9LTkB4';
  final Mode _mode = Mode.overlay;

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
}
