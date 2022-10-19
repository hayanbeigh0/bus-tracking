import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '/models/user_location.dart';
import '/screens/bottom_navigation/google_map_view.dart';

import '../models/driver_location.dart';

IO.Socket socket = IO.io('https://iust-bus-track.herokuapp.com',
    OptionBuilder().setTransports(['websocket']).build());
final StreamController<UserCurrentLocation> userLocationController =
    StreamController<UserCurrentLocation>.broadcast();
final StreamController<DriverCurrentLocation> busLocationController =
    StreamController<DriverCurrentLocation>.broadcast();
final StreamController<List<dynamic>> listBusLocationController =
    StreamController<List<dynamic>>.broadcast();

late UserCurrentLocation userCurrentLocation;
late DriverCurrentLocation driverCurrentLocation;
late List<dynamic> list;
connectAndListen() {
  print('starting connection');
  socket.onConnect((_) {
    print('connect');
    socket.emit('ping', 'nowgam');
  });

  //When an event recieved from server, data is added to the stream
  socket.on('TC-busData', (data) {
    list = jsonDecode(data);
    print(list);
    var result = DriverCurrentLocation.fromJson(jsonDecode(data)[0]);
    driverCurrentLocation = DriverCurrentLocation(
      latitude: result.latitude,
      longitude: result.longitude,
      speed: result.speed,
      name: result.name,
    );
    listBusLocationController.add(list);
    busLocationController.add(result);
  });
  socket.on('TC-busActiveStatus', (data) {
    print(jsonDecode(data));
    var result = json.decode(data);
    MapSampleState().removeAbsentBusMarker(result['busNumber'].toString());
  });

  Geolocator.getPositionStream().listen((event) {
    userCurrentLocation = UserCurrentLocation(
      latitude: event.latitude,
      longitude: event.longitude,
      speed: event.speed,
    );
    userLocationController.add(userCurrentLocation);
  });
  socket.onError((data) => print(data));
  socket.onReconnect((data) => print('reconnected'));
  socket.onDisconnect((_) => print('disconnect'));
}

Stream<UserCurrentLocation> getUserCurrentLocation() {
  return userLocationController.stream;
}

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

Stream<DriverCurrentLocation> getBusLiveLocation() {
  return busLocationController.stream;
}

Stream<List<dynamic>> getListBusLiveLocation() {
  return listBusLocationController.stream;
}
