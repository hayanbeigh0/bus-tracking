import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../utils/color.dart';
import '/screens/authentication_screens/registration_screens/student_registration/set_password.dart';

class PickupAndDropPoint extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String studentRegistration;
  final String busNumber;

  PickupAndDropPoint({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentRegistration,
    required this.busNumber,
  });
  @override
  State<PickupAndDropPoint> createState() => _PickupAndDropPointState();
}

class _PickupAndDropPointState extends State<PickupAndDropPoint> {
  static final _formKey = GlobalKey<FormState>();

  Set<Marker> _markers = {};
  Completer<GoogleMapController> _controller = Completer();
  final String mapBoxToken =
      'pk.eyJ1IjoiaGF5YW5iZWlnaCIsImEiOiJja3NnM3h2bWIxZHdlMnBvNGQzbHdrbTBlIn0.aCx8YWmxFL5dhaDytJ84OQ';
  // late MapboxMapController mapController;
  late final StreamController<Position> _positionStreamController =
      StreamController<Position>();
  double latitude = 0.0;
  double longitude = 0.0;
  late double pickedLongitude;
  late double pickedLatitude;

  late LatLng pickedLocation;

  late var posLoc;
  late final symbol;

  // Symbol symbolOption(double latitude, double longitude) {
  //   symbol = mapController.addSymbol(
  //     SymbolOptions(
  //       geometry: LatLng(
  //         latitude,
  //         longitude,
  //       ),
  //       draggable: true,
  //       iconImage: 'asset/location.png',
  //       iconSize: 2.0,
  //     ),
  //   );
  //   return symbol;
  // }

  Stream<Position> locationUpdates() {
    Geolocator.getPositionStream().listen((position) {
      _positionStreamController.sink.add(position);
    });
    return _positionStreamController.stream;
  }

  @override
  void initState() {
    locationUpdates();
    super.initState();
  }

  // _onMapCreated(MapboxMapController mapController) async {
  //   this.mapController = mapController;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Location')),
      body: Stack(
        children: [
          StreamBuilder(
            stream: _positionStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                posLoc = snapshot.data;
                latitude = posLoc.latitude;
                longitude = posLoc.longitude;
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                      latitude,
                      longitude,
                    ),
                    zoom: 10.4746,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  onTap: (argument) {
                    pickedLatitude = argument.latitude;
                    pickedLongitude = argument.longitude;
                    print('$pickedLatitude, $pickedLongitude');
                    setState(() {
                      _markers = {};
                      _markers.add(
                        Marker(
                          markerId: const MarkerId('pickupPointLocation'),
                          infoWindow: const InfoWindow(title: 'Pickup Point'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue),
                          position: LatLng(
                            argument.latitude,
                            argument.longitude,
                          ),
                        ),
                      );
                    });
                  },
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                );
              } else {
                return Center(
                  child: SpinKitCircle(
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? ColorStyle.progressIndicatorColor
                              : ColorStyle.progressIndicatorColor,
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: () {
                if (pickedLatitude == 0.0 || pickedLongitude == 0.0) {
                  return;
                }
                print('$pickedLatitude, $pickedLongitude');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SetPassword(
                      firstName: widget.firstName,
                      lastName: widget.lastName,
                      email: widget.email,
                      studentRegistration: widget.studentRegistration,
                      busNumber: widget.busNumber,
                      pickedLatitude: pickedLatitude,
                      pickedLongitude: pickedLongitude,
                    ),
                  ),
                );
              },
              child: const Text('Pick marked location'),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // _positionStreamController.close();
    // mapController.dispose();

    super.dispose();
  }
}

// return MapboxMap(
//                   initialCameraPosition: CameraPosition(
//                     target: LatLng(
//                       latitude,
//                       longitude,
//                     ),
//                     zoom: 16,
//                   ),
//                   dragEnabled: true,
                  // onMapClick: (point, coordinates) {
                  //   mapController.clearSymbols();
                  //   pickedLocation = coordinates;
                  //   symbolOption(coordinates.latitude, coordinates.longitude);
                  // },
//                   myLocationEnabled: true,
//                   myLocationRenderMode: MyLocationRenderMode.COMPASS,
//                   compassViewPosition: CompassViewPosition.TopRight,
//                   accessToken: mapBoxToken,
//                   zoomGesturesEnabled: true,
//                   compassEnabled: true,
//                   onMapCreated: (controller) {
//                     _onMapCreated(controller);
//                   },
//                 );