import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../models/user_location.dart';

class LocationServices {
  late UserCurrentLocation currentLocation;

  final StreamController<UserCurrentLocation> _locationController =
      StreamController<UserCurrentLocation>.broadcast();
  late Position userLocation;

  Stream<UserCurrentLocation> get locationStream => _locationController.stream;
  LocationServices() {
    Geolocator.requestPermission().then((value) {
      if (value == LocationPermission.whileInUse ||
          value == LocationPermission.always) {
        Geolocator.getPositionStream().listen((locationData) {
          _locationController.add(
            UserCurrentLocation(
              latitude: locationData.latitude,
              longitude: locationData.longitude,
              speed: locationData.speed,
            ),
          );
        });
      }
    });
  }

  getLocation() async {
    try {
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
      // var userLocation = await Geolocator.getCurrentPosition();
      // currentLocation = UserLocation(
      //   latitude: userLocation.latitude,
      //   longitude: userLocation.longitude,
      // );
      // _locationController.add(currentLocation);
      Geolocator.getPositionStream().listen((locationData) {
        _locationController.add(
          UserCurrentLocation(
            latitude: locationData.latitude,
            longitude: locationData.longitude,
            speed: locationData.speed,
          ),
        );
      });
      // ignore: empty_catches
    } catch (e) {}
  }

  checkPermissions() async {}
}
