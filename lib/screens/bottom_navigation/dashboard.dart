import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iust_bus_tracking/screens/authentication_screens/login_screens/student_login.dart';

import 'package:provider/provider.dart';
import '/models/user_location.dart';
import '/provider/user_location.dart';
import '/screens/authentication_screens/login_screens/login_options.dart';
import '/screens/driver_home_screen.dart';
import '/screens/welcome.dart';

import '../../models/driver_location.dart';
import '../../utils/color.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser != null) {
      _usersStream = FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .snapshots();
    }
    connectAndListen();
    setupToken();
    super.initState();
  }

  late String _token;
  late double stopLatitude;
  late double stopLongitude;
  double cardContentFontSize = 15;
  double cardTitleFontSize = 17;
  late var stopLocation;
  late var busNumber;
  late var busData;
  late Map<String, dynamic> busDistanceFromTheStop;
  late Map<String, dynamic> universityDistanceFromTheBus;
  late DriverCurrentLocation drCurrentLocation;

  Future<void> setupToken() async {
    if (FirebaseAuth.instance.currentUser == null) {
      return;
    }
    // Get the token each time the application loads
    String? token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  late final Stream<DocumentSnapshot> _usersStream;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 150,
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: ColorStyle.colorPrimary,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60.0),
              bottomRight: Radius.circular(60.0),
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Text(
                'DASHBOARD',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        FirebaseAuth.instance.currentUser != null
            ? Expanded(
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  color: Color.fromARGB(255, 255, 255, 255),
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: _usersStream,
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                            child: Text("Something went wrong"));
                      }

                      // if (snapshot.hasData) {
                      //   Navigator.of(context).pushReplacement(MaterialPageRoute(
                      //     builder: (context) => StudentLoginScreen(),
                      //   ));
                      //   return const Center(
                      //     child: Text("You are not registered as a user!"),
                      //   );
                      // }
                      if (snapshot.hasData) {
                        Map<String, dynamic> data =
                            snapshot.data!.data() as Map<String, dynamic>;
                        stopLatitude = data['pickedLatitude'];
                        stopLongitude = data['pickedLongitude'];
                        busNumber = data['busNumber'];
                        print('bus num: $busNumber');
                        return StreamBuilder<UserCurrentLocation>(
                          stream: getUserCurrentLocation(),
                          builder: (context, userCurrentLocation) {
                            if (userCurrentLocation.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: Text('Getting Location Data...'),
                              );
                            }
                            if (userCurrentLocation.hasError) {
                              return const Center(
                                child: Text('Something went wrong!'),
                              );
                            }
                            if (userCurrentLocation.hasData) {
                              return StreamBuilder<List<dynamic>>(
                                stream: getListBusLiveLocation(),
                                builder: (context, snaps) {
                                  if (snaps.hasData) {
                                    busData = snaps.data!.firstWhere(
                                      (element) =>
                                          element['busNumber'] ==
                                          int.parse(busNumber),
                                      orElse: () => [],
                                    );
                                    if (busData.isNotEmpty) {
                                      drCurrentLocation = DriverCurrentLocation(
                                        busNumber: busData['busNumber'],
                                        isActive: busData['isActive'],
                                        latitude: busData['latitude'],
                                        longitude: busData['longitude'],
                                        name: busData['name'],
                                        phoneNumber: busData['phone'],
                                        speed: busData['speed'],
                                      );
                                    }
                                    String userDistanceFromTheStop =
                                        calculateUserDistanceFromTheStop(
                                      userCurrentLocation: userCurrentLocation
                                          .data as UserCurrentLocation,
                                    );
                                    if (busData.isNotEmpty) {
                                      busDistanceFromTheStop =
                                          calculateBusDistanceFromTheStop(
                                        driverCurrentLocation:
                                            drCurrentLocation,
                                      );
                                      universityDistanceFromTheBus =
                                          calculateUniversityDistanceFromTheBus(
                                        driverCurrentLocation:
                                            drCurrentLocation,
                                      );
                                    }
                                    return Center(
                                      child: busData.isNotEmpty
                                          ? Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                SizedBox(
                                                  height: 30,
                                                ),
                                                Card(
                                                  elevation: 4,
                                                  shadowColor:
                                                      ColorStyle.colorPrimary,
                                                  borderOnForeground: true,
                                                  clipBehavior: Clip.antiAlias,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    color: ColorStyle
                                                        .colorPrimaryLight,
                                                    // color: Color.fromARGB(
                                                    //     138, 229, 227, 227),
                                                    padding:
                                                        const EdgeInsets.all(
                                                      12.0,
                                                    ),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Driver Info',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  cardTitleFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            'Bus No: ${data['busNumber']}',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  cardContentFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            busData['isActive'] ==
                                                                    true
                                                                ? 'Driver Name: ${busData['name']}'
                                                                : 'Driver Name: NA',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  cardContentFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            busData['isActive'] ==
                                                                    true
                                                                ? 'Phone: ${busData['phone']}'
                                                                : 'Phone: NA',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  cardContentFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Card(
                                                  elevation: 4,
                                                  shadowColor:
                                                      ColorStyle.colorPrimary,
                                                  borderOnForeground: true,
                                                  clipBehavior: Clip.antiAlias,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    color: ColorStyle
                                                        .colorPrimaryLight,
                                                    padding:
                                                        const EdgeInsets.all(
                                                      12.0,
                                                    ),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Bus Stats',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  cardTitleFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 10,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text(
                                                                'Bus Status: ',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      cardTitleFontSize,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              Text(
                                                                busData['isActive'] ==
                                                                        true
                                                                    ? 'Active'
                                                                    : 'Inactive',
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      cardTitleFontSize,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          busData['isActive'] ==
                                                                  false
                                                              ? SizedBox()
                                                              : Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'Distance to your stop: ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                cardContentFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          busDistanceFromTheStop[
                                                                              "distance"],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                cardContentFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'EST time to your stop: ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                cardContentFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          busDistanceFromTheStop[
                                                                              "time"],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                cardContentFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'Distance to your University: ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                cardContentFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          universityDistanceFromTheBus[
                                                                              "distance"],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                cardContentFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Text(
                                                                          'EST time to your University: ',
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                cardContentFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          universityDistanceFromTheBus[
                                                                              "time"],
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                cardContentFontSize,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 20,
                                                ),
                                                Card(
                                                  elevation: 4,
                                                  shadowColor:
                                                      ColorStyle.colorPrimary,
                                                  borderOnForeground: true,
                                                  clipBehavior: Clip.antiAlias,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10,
                                                    ),
                                                  ),
                                                  child: Container(
                                                    color: ColorStyle
                                                        .colorPrimaryLight,
                                                    padding:
                                                        const EdgeInsets.all(
                                                      12.0,
                                                    ),
                                                    child: SizedBox(
                                                      width: double.infinity,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            'Your Stats',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  cardTitleFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            'Your Distance from the stop: $userDistanceFromTheStop',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  cardContentFontSize,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : SizedBox(
                                              width: double.infinity,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    'Your bus (Bus no: $busNumber) is currently inactive!',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const Text(
                                                    'You can still check the live location of other buses on the Maps',
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            ),
                                    );
                                  }
                                  return Center(
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Your bus (Bus no: $busNumber) is currently inactive!',
                                            textAlign: TextAlign.center,
                                          ),
                                          const Text(
                                            'You can still check the live location of other buses on the Maps',
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }
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
                          },
                        );
                      }
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
                    },
                  ),
                ),
              )
            : Expanded(
                child: SizedBox(
                  // height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Please Login to view this page!',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                            (Route<dynamic> route) => false,
                          );
                        },
                        child: const Text(
                          'Go to Login!',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  String calculateUserDistanceFromTheStop({
    required UserCurrentLocation userCurrentLocation,
  }) {
    double distance = Geolocator.distanceBetween(
      userCurrentLocation.latitude as double,
      userCurrentLocation.longitude as double,
      stopLatitude,
      stopLongitude,
    );
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)}Km';
    }
    return '${distance.toStringAsFixed(1)}m';
  }

  Map<String, dynamic> calculateBusDistanceFromTheStop({
    required DriverCurrentLocation driverCurrentLocation,
  }) {
    double distance = Geolocator.distanceBetween(
      driverCurrentLocation.latitude as double,
      driverCurrentLocation.longitude as double,
      stopLatitude,
      stopLongitude,
    );
    double time = distance / 9.7;
    if (distance >= 1000) {
      return {
        'distance': '${(distance / 1000).toStringAsFixed(1)}Km',
        'time': (time > 60 && time < 3600)
            ? '${(time / 60).toStringAsFixed(1)}min'
            : (time < 60)
                ? '${time.toStringAsFixed(1)}s'
                : '${(time / 3600).toStringAsFixed(1)}hr'
      };
    }
    return {
      'distance': '${distance.toStringAsFixed(1)}m',
      'time': (time > 60 && time < 3600)
          ? '${(distance / 9.7).toStringAsFixed(1)}min'
          : (time < 60)
              ? '${time.toStringAsFixed(1)}s'
              : '${(time / 3600).toStringAsFixed(1)}hr'
    };
  }

  Map<String, dynamic> calculateUniversityDistanceFromTheBus({
    required DriverCurrentLocation driverCurrentLocation,
  }) {
    double distance = Geolocator.distanceBetween(
      driverCurrentLocation.latitude as double,
      driverCurrentLocation.longitude as double,
      33.92661,
      75.01746,
    );
    double time = distance / 9.7;
    if (distance >= 1000) {
      return {
        'distance': '${(distance / 1000).toStringAsFixed(1)}Km',
        'time': (time > 60 && time < 3600)
            ? '${(time / 60).toStringAsFixed(1)}min'
            : (time < 60)
                ? '${(distance / 9.7).toStringAsFixed(1)}s'
                : '${(distance / 9.7).toStringAsFixed(1)}hr'
      };
    }
    return {
      'distance': '${distance.toStringAsFixed(1)}m',
      'time': (time > 60 && time < 3600)
          ? '${(distance / 9.7).toStringAsFixed(1)}min'
          : (time < 60)
              ? '${(distance / 9.7).toStringAsFixed(1)}s'
              : '${(distance / 9.7).toStringAsFixed(1)}hr'
    };
  }
}

Future<void> saveTokenToDatabase(String token) async {
  // Assume user is logged in for this example
  String userId = FirebaseAuth.instance.currentUser!.uid;
  await FirebaseFirestore.instance.collection('user').doc(userId).update({
    'tokens': FieldValue.arrayUnion([token]),
  }).onError((error, stackTrace) async =>
      await FirebaseFirestore.instance.collection('driver').doc(userId).update({
        'tokens': FieldValue.arrayUnion([token]),
      }).onError((error, stackTrace) => print('An error has occured: $error')));
}

getPickedLocation() {
  FirebaseFirestore.instance
      .collection('user')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
}

showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message.toString(),
      ),
    ),
  );
}
