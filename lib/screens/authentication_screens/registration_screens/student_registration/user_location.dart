import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latLng;

import '../../../../utils/color.dart';

class UserLocation extends StatefulWidget {
  const UserLocation({Key? key}) : super(key: key);

  @override
  State<UserLocation> createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {
  final String mapBoxToken =
      'pk.eyJ1IjoiaGF5YW5iZWlnaCIsImEiOiJja3NnM3h2bWIxZHdlMnBvNGQzbHdrbTBlIn0.aCx8YWmxFL5dhaDytJ84OQ';
  late final StreamController<Position> _positionStreamController =
      StreamController<Position>();
  double latitude = 0.0;
  double longitude = 0.0;

  late var posLoc;

  Future<String> locationUpdates() async {
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
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    _positionStreamController.sink.add(position);
    return position.toString();
  }

  @override
  void initState() {
    Timer.periodic(
      const Duration(
        seconds: 2,
      ),
      (timer) {
        locationUpdates();
      },
    );
    super.initState();
  }

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
                return MapView(latitude: latitude, longitude: longitude);
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    _positionStreamController.close();
    super.dispose();
  }
}

class MapView extends StatefulWidget {
  MapView({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  double latitude;
  double longitude;

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  double pickedLatitude = 0.0;
  double pickedLongitude = 0.0;
  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        enableScrollWheel: true,
        center: latLng.LatLng(widget.latitude, widget.longitude),
        zoom: 16.0,
        maxZoom: 18,
        onTap: (tapPosition, point) {
          setState(() {
            pickedLatitude = point.latitude;
            pickedLongitude = point.longitude;
          });
        },
      ),
      layers: [
        TileLayerOptions(
          urlTemplate:
              'https://api.mapbox.com/styles/v1/hayanbeigh/cl3xa65e0000814jsb8woy0t1/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiaGF5YW5iZWlnaCIsImEiOiJja3NnM3h2bWIxZHdlMnBvNGQzbHdrbTBlIn0.aCx8YWmxFL5dhaDytJ84OQ',
          additionalOptions: {
            'accessToken':
                'pk.eyJ1IjoiaGF5YW5iZWlnaCIsImEiOiJja3NnM3h2bWIxZHdlMnBvNGQzbHdrbTBlIn0.aCx8YWmxFL5dhaDytJ84OQ',
            'id': 'mapbox.mapbox-streets-v8'
          },
          fastReplace: true,
        ),
        MarkerLayerOptions(
          markers: [
            Marker(
              rotate: true,
              width: 80.0,
              height: 80.0,
              point: latLng.LatLng(widget.latitude, widget.longitude),
              builder: (ctx) => Transform.translate(
                offset: const Offset(0, -10),
                child: const Icon(
                  Icons.location_on,
                  size: 46,
                  color: Color.fromARGB(255, 19, 123, 227),
                ),
              ),
            ),
            if (pickedLatitude != 0.0 && pickedLongitude != 0.0)
              Marker(
                rotate: true,
                width: 80.0,
                height: 80.0,
                point: latLng.LatLng(pickedLatitude, pickedLongitude),
                builder: (ctx) => Transform.translate(
                  offset: const Offset(0, -10),
                  child: const Icon(
                    Icons.location_on,
                    size: 46,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // List<Marker> markerList = [
  //   Marker(
  //     width: 80.0,
  //     height: 80.0,
  //     point: latLng.LatLng(widget.latitude, widget.longitude),
  //     builder: (ctx) => Transform.translate(
  //       offset: const Offset(0, -10),
  //       child: const Icon(
  //         Icons.location_on,
  //         size: 46,
  //         color: Color.fromARGB(255, 19, 123, 227),
  //       ),
  //     ),
  //   ),
  // ];
}
