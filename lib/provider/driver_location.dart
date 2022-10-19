import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '/provider/user_location.dart';
import '../models/driver_location.dart';

IO.Socket socket = IO.io(
    'https://iust-bus-track.herokuapp.com',
// IO.Socket socket = IO.io("192.168.29.191:4000",
    OptionBuilder().setTransports(['websocket']).build());
final StreamController<DriverCurrentLocation> driverLocationController =
    StreamController<DriverCurrentLocation>.broadcast();
late DriverCurrentLocation driverCurrentLocation;
late Position currentLocation;
bool shouldFetchLocation = true;
bool sendActiveStatus = true;
connectAndSendLocation(int busNumber, String driverName, String phoneNumber) {
  print(busNumber);
  socket.connect();
  socket.onConnect((_) {
    shouldFetchLocation = true;
    if (sendActiveStatus) {
      socket.emit(
        'TS-busActiveStatus',
        jsonEncode({'busNumber': busNumber, 'isActive': true}),
      );
      sendActiveStatus = false;
    }
  });

  Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
    accuracy: LocationAccuracy.best,
  )).listen((event) {
    driverCurrentLocation = DriverCurrentLocation(
      name: driverName,
      latitude: event.latitude,
      longitude: event.longitude,
      speed: event.speed,
      busNumber: busNumber,
      phoneNumber: phoneNumber,
      isActive: true,
    );

    driverLocationController.add(driverCurrentLocation);
    if (shouldFetchLocation) {
      socket.emit('TS-busData', jsonEncode(driverCurrentLocation));
    }
  });
  socket.onError((data) => print(data));
  socket.onReconnect((data) => print('Driver reconnected'));
  socket.onDisconnect((_) {
    disconnectAndStopSharingDriverLocation(busNumber);
  });
}

disconnectAndStopSharingDriverLocation(int busNum) async {
  shouldFetchLocation = false;
  // await Future.delayed(const Duration(seconds: 4));
  socket.emit(
    'TS-busActiveStatus',
    jsonEncode({'busNumber': busNum, 'isActive': false}),
  );
  await Future.delayed(const Duration(seconds: 2));
  socket.disconnect();
}

reconnectAndStartSharingDriverLocation() {
  socket.connect();
}

Stream<DriverCurrentLocation> getBusLocation() {
  return driverLocationController.stream;
}
