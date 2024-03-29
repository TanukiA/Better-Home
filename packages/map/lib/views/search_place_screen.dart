import 'package:flutter/material.dart';
import 'package:map/controllers/location_controller.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen(
      {Key? key,
      required this.controller,
      required this.purpose,
      this.userType})
      : super(key: key);
  final LocationController controller;
  final String purpose;
  final String? userType;

  @override
  StateMVC<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends StateMVC<SearchPlaceScreen> {
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
    super.initState();
  }

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
                Positioned(
                  top: 20,
                  left: 30,
                  child: SizedBox(
                    width: 128,
                    height: 53,
                    child: ElevatedButton(
                      onPressed: () => widget.controller.handleSearchButton(
                          context, homeScaffoldKey, displayPrediction),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(46, 125, 45, 1),
                        padding: const EdgeInsets.all(16.0),
                      ),
                      child: const Text(
                        "Search Place",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: ElevatedButton(
              onPressed: () {
                if (widget.purpose == "register") {
                  widget.controller
                      .handleConfirmButton1(context, selectedAddress, lat, lng);
                } else if (widget.purpose == "service") {
                  widget.controller
                      .handleConfirmButton2(context, selectedAddress, lat, lng);
                } else {
                  widget.controller.handleConfirmButton3(
                      context, selectedAddress, lat, lng, widget.userType!);
                }
              },
              style: confirmBtnStyle,
              child: const Text("Confirm"),
            ),
          ),
        ],
      ),
    );
  }

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
}
