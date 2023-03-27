import 'package:flutter/material.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:map/models/map_service.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:better_home/utils.dart';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen({Key? key, required this.controller})
      : super(key: key);
  final LocationController controller;

  @override
  StateMVC<SearchPlaceScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends StateMVC<SearchPlaceScreen> {
  late MapService _map;
  late GoogleMapController googleMapController;

  String? selectedAddress;
  double? lat;
  double? lng;

  static const CameraPosition initialCameraPosition =
      CameraPosition(target: LatLng(3.0738, 101.5183), zoom: 14.0);
  final homeScaffoldKey = GlobalKey<ScaffoldState>();
  Set<Marker> markersList = {};

  @override
  void initState() {
    _map = widget.controller.map;
    super.initState();
  }

  Future<void> loginBtnClicked() async {}

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final ButtonStyle confirmBtnStyle = ElevatedButton.styleFrom(
      textStyle: const TextStyle(
        fontSize: 20,
        fontFamily: 'Roboto',
      ),
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      fixedSize: Size(size.width * 0.8, 55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 3,
      shadowColor: Colors.grey[400],
    );

    return Scaffold(
      key: homeScaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Set Your Address',
          style: TextStyle(
            fontSize: 25,
            fontFamily: 'Roboto',
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromRGBO(182, 162, 110, 1),
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        iconTheme: const IconThemeData(
          size: 40,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: initialCameraPosition,
                  markers: markersList,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    googleMapController = controller;
                  },
                ),
                ElevatedButton(
                    onPressed: () => widget.controller.handleSearchButton(
                        context, homeScaffoldKey, displayPrediction),
                    child: const Text("Search Place")),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: _handleConfirmButton,
            style: confirmBtnStyle,
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

/*
  Future<void> _handleSearchButton() async {
    Prediction? p = await PlacesAutocomplete.show(
        context: context,
        apiKey: kGoogleApiKey,
        onError: handleError,
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

    displayPrediction(p!, homeScaffoldKey.currentState);
  }

  void handleError(PlacesAutocompleteResponse response) {
    showSnackBar(context, response.errorMessage!);
  }
*/
  void displayPrediction(Prediction p, ScaffoldState? currentState) async {
    GoogleMapsPlaces places = GoogleMapsPlaces(
        apiKey: widget.controller.getApiKey(),
        apiHeaders: await const GoogleApiHeaders().getHeaders());

    PlacesDetailsResponse detail = await places.getDetailsByPlaceId(p.placeId!);

    lat = detail.result.geometry!.location.lat;
    lng = detail.result.geometry!.location.lng;
    selectedAddress = p.description!;

    markersList.clear();
    markersList.add(Marker(
        markerId: const MarkerId("0"),
        position: LatLng(lat!, lng!),
        infoWindow: InfoWindow(title: detail.result.name)));

    setState(() {});

    googleMapController
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat!, lng!), 14.0));
  }

  Future<void> _handleConfirmButton() async {
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
}
