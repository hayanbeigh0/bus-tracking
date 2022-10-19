import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iust_bus_tracking/utils/color.dart';
import '../../widgets/text_form_field_container.dart';
import '/provider/user_location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';

import '../../models/driver_location.dart';
import '../../models/user_location.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  List<DriverCurrentLocation> busesData = [];
  List<dynamic> myBus = [];
  Set<Marker> busLocationMarkers = {};
  BitmapDescriptor busLocationMarker = BitmapDescriptor.defaultMarker;
  @override
  void initState() {
    setCustomMarkerIcon();
    super.initState();
  }

  setCustomMarkerIcon() async {
    await BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      "asset/bus-stop.png",
    ).then((icon) {
      setState(() {
        busLocationMarker = icon;
      });
      return busLocationMarker;
    });
  }

  double busLatitude = 0.0;
  double busLongitude = 0.0;
  double userLatitude = 0.0;
  double userLongitude = 0.0;
  late double pickedLongitude;
  late double pickedLatitude;
  late LatLng pickedLocation;

  final Completer<GoogleMapController> _controller = Completer();

  final MapType _currentMapType = MapType.normal;
  bool viewMyBusOnly = false;
  String buttonText = 'My Bus';
  bool activeJourney = false;
  bool showProgressIndicator = false;
  bool disableButton = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FirebaseAuth.instance.currentUser != null
          ? FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshots) {
                if (snapshots.hasError) {
                  return const Text("Something went wrong");
                }

                if (snapshots.hasData && !snapshots.data!.exists) {
                  return const Text("Document does not exist");
                }

                if (snapshots.connectionState == ConnectionState.done) {
                  Map<String, dynamic> data =
                      snapshots.data!.data() as Map<String, dynamic>;

                  return StreamBuilder<UserCurrentLocation>(
                    stream: getUserCurrentLocation(),
                    builder: (context, snp) {
                      if (snp.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Text('Getting Location Data...'),
                        );
                      }
                      if (snp.hasError) {
                        return const Center(
                          child: Text('Something went wrong!'),
                        );
                      }
                      if (snp.hasData) {
                        busLocationMarkers.add(Marker(
                          markerId: const MarkerId('pickupPointLocation'),
                          infoWindow: const InfoWindow(title: 'Pickup Point'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueBlue),
                          position: LatLng(
                            data['pickedLatitude'] as double,
                            data['pickedLongitude'] as double,
                          ),
                        ));
                      }

                      return StreamBuilder<List<dynamic>>(
                        stream: getListBusLiveLocation(),
                        builder: (context, snaps) {
                          if (snaps.hasError) {
                            return Center(
                              child: Text(snaps.error.toString()),
                            );
                          }
                          if (snaps.hasData) {
                            busesData = [];
                            busLocationMarkers = {};
                            myBus = viewMyBusOnly
                                ? snaps.data!.where((element) {
                                    // print('element ${element['busNumber']}');
                                    // print('data ${data['busNumber']}');
                                    return int.parse(
                                            element['busNumber'].toString()) ==
                                        int.parse(data['busNumber'].toString());
                                  }).toList()
                                : snaps.data!;
                            // print('my bus data : ${myBus.length}');
                            for (var element in myBus) {
                              busesData.add(
                                DriverCurrentLocation(
                                  busNumber: element['busNumber'],
                                  latitude: element['latitude'],
                                  longitude: element['longitude'],
                                  speed: element['speed'],
                                ),
                              );
                            }
                            if (busesData.length != 0) {
                              busLatitude = busesData[0].latitude as double;
                              busLongitude = busesData[0].longitude as double;
                            }

                            for (var element in busesData) {
                              busLocationMarkers.add(
                                Marker(
                                  markerId:
                                      MarkerId(element.busNumber.toString()),
                                  infoWindow: InfoWindow(
                                      title: 'Bus No. ${element.busNumber}'),
                                  icon: busLocationMarker,
                                  position: LatLng(
                                    element.latitude as double,
                                    element.longitude as double,
                                  ),
                                ),
                              );
                            }
                          }
                          return Stack(
                            children: [
                              GoogleMap(
                                mapType: MapType.normal,
                                mapToolbarEnabled: true,
                                markers: busLocationMarkers,
                                initialCameraPosition: CameraPosition(
                                  target: LatLng(
                                    snp.data!.latitude as double,
                                    snp.data!.longitude as double,
                                  ),
                                  zoom: 12.4746,
                                ),
                                padding: const EdgeInsets.only(top: 40.0),
                                zoomGesturesEnabled: true,
                                // zoomControlsEnabled: true,
                                compassEnabled: true,
                                myLocationEnabled: true,
                                onMapCreated: (GoogleMapController controller) {
                                  _controller.complete(controller);
                                },
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: SafeArea(
                                  child: SizedBox(
                                    height: 60,
                                    width: 190,
                                    child: TextFormFieldContainer(
                                      backgroundColor:
                                          Color.fromARGB(138, 255, 255, 255),
                                      noTopRightRadius: true,
                                      noBottomRightRadius: true,
                                      borderRadius: 12,
                                      padding: 0,
                                      textForm: DropdownButtonFormField(
                                        style: TextStyle(
                                          color: ColorStyle.colorPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        iconEnabledColor: Colors.transparent,
                                        iconSize: 0,
                                        value: 'All Buses',
                                        decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.keyboard_arrow_down,
                                            color: ColorStyle.colorPrimary,
                                          ),
                                          labelStyle: TextStyle(
                                            color: Color.fromARGB(
                                                255, 255, 255, 255),
                                            fontSize: 14,
                                          ),
                                          border: InputBorder.none,
                                        ),
                                        items: [
                                          'All Buses',
                                          'My Bus Only',
                                        ]
                                            .map(
                                              (item) =>
                                                  DropdownMenuItem<String>(
                                                value: item,
                                                child: Text(
                                                  item,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value == 'My Bus Only') {
                                            viewMyBusOnly = true;
                                          } else {
                                            viewMyBusOnly = false;
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  );
                }
                return const Center(
                  child: Text('Loading...'),
                );
              },
            )
          : StreamBuilder<List<dynamic>>(
              stream: getListBusLiveLocation(),
              builder: (context, snapsht) {
                busesData = [];
                busLocationMarkers = {};
                if (snapsht.hasError) {
                  return Center(
                    child: Text(snapsht.error.toString()),
                  );
                }

                if (snapsht.hasData) {
                  for (var element in snapsht.data!) {
                    busesData.add(
                      DriverCurrentLocation(
                        busNumber: element['busNumber'],
                        latitude: element['latitude'],
                        longitude: element['longitude'],
                        speed: element['speed'],
                      ),
                    );
                  }
                  for (var element in busesData) {
                    busLocationMarkers.add(
                      Marker(
                        markerId: MarkerId(element.busNumber.toString()),
                        infoWindow:
                            InfoWindow(title: 'Bus No. ${element.busNumber}'),
                        icon: busLocationMarker,
                        position: LatLng(
                          element.latitude as double,
                          element.longitude as double,
                        ),
                      ),
                    );
                  }
                  busLatitude = snapsht.data![0]['latitude'];
                  busLongitude = snapsht.data![0]['longitude'];
                }
                return StreamBuilder<UserCurrentLocation>(
                    stream: getUserCurrentLocation(),
                    builder: (context, snp) {
                      if (snp.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Text('Getting Location Data...'),
                        );
                      }
                      if (snp.hasError) {
                        return const Center(
                          child: Text('Something went wrong!'),
                        );
                      }

                      return GoogleMap(
                        mapType: MapType.normal,
                        mapToolbarEnabled: true,
                        markers: busLocationMarkers,
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            snp.data!.latitude as double,
                            snp.data!.longitude as double,
                          ),
                          zoom: 16.151926040649414,
                        ),
                        zoomGesturesEnabled: true,
                        compassEnabled: true,
                        myLocationEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                      );
                    });
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (busLatitude == 0.0 || busLongitude == 0.0) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('No Bus available!'),
                action: SnackBarAction(
                  label: 'Ok',
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
            return;
          } else {
            _goToTheBus();
          }
        },
        label: const Text('To the Bus!'),
        icon: const Icon(Icons.bus_alert),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
    );
  }

  doNothing() {}

  Future<void> _goToTheBus() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            busLatitude,
            busLongitude,
          ),
          zoom: 16.151926040649414,
        ),
      ),
    );
  }

  removeAbsentBusMarker(String busNumber) {
    busLocationMarkers.removeWhere(
        (element) => element.markerId == MarkerId(busNumber.toString()));
    if (list.length <= 1) {
      listBusLocationController.add([
        {
          'busNumber': int.parse(busNumber),
          'isActive': false,
          'latitude': 0.0,
          'longitude': 0.0,
          'speed': 0.0,
        }
      ]);
    }
    // print(busesData.length);
  }
}

IO.Socket socket = IO.io('ws://192.168.29.191:4000',
    OptionBuilder().setTransports(['websocket']).build());
final StreamController<UserCurrentLocation> userLocationController =
    StreamController<UserCurrentLocation>.broadcast();
final StreamController<DriverCurrentLocation> busLocationController =
    StreamController<DriverCurrentLocation>.broadcast();

late UserCurrentLocation userCurrentLocation;
late DriverCurrentLocation driverCurrentLocation;
checkLocationPermissions() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
}
