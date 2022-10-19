import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:iust_bus_tracking/screens/admin_home_screen.dart';
import 'package:provider/provider.dart';
import '/models/user_location.dart';
import '/provider/user_location.dart';
import '/screens/authentication_screens/home_screen.dart';
import '/screens/driver_home_screen.dart';
import '/utils/color.dart';
import './screens/welcome.dart';
import 'firebase_options.dart';
import 'models/driver_location.dart';
import 'provider/driver_location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool userLoggedIn;
  late String userType = 'null';
  @override
  void initState() {
    userLoggedIn = checkIfUserIsLoggedIn();
    if (userLoggedIn) {
      checkUserType();
      setState(() {
        userType;
      });
    }
    checkLocationPermissions();
    super.initState();
  }

  bool checkIfUserIsLoggedIn() {
    if (FirebaseAuth.instance.currentUser == null) {
      return false;
    } else {
      FirebaseFirestore.instance
          .collection('user')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      return true;
    }
  }

  checkUserType() async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      if (value.exists) {
        setState(() {
          userType = 'user';
        });
        return true;
      } else {
        FirebaseFirestore.instance
            .collection('driver')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          if (value.exists) {
            setState(() {
              userType = 'driver';
            });
            return true;
          } else {
            FirebaseFirestore.instance
                .collection('admin')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get()
                .then((value) {
              if (value.exists) {
                setState(() {
                  userType = 'admin';
                });
                return true;
              } else {}
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: ColorStyle.colorPrimary,
          secondary: ColorStyle.colorPrimaryLight,
        ),
      ),
      home: userLoggedIn
          ? userType != 'null'
              ? FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection(userType)
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get(),
                  builder: (BuildContext context,
                      AsyncSnapshot<DocumentSnapshot> snapshots) {
                    if (snapshots.hasError) {
                      return Center(child: Text(snapshots.error.toString()));
                    }
                    if (snapshots.hasData && !snapshots.data!.exists) {
                      return Scaffold(
                        body: Center(
                          child: Text('wrong'),
                        ),
                      );
                      // return AdminHomeScreen();
                    }
                    if (snapshots.connectionState == ConnectionState.done) {
                      Map<String, dynamic> data =
                          snapshots.data!.data() as Map<String, dynamic>;
                      if (data['userType'] == 'admin') {
                        return AdminHomeScreen();
                      } else if (data['userType'] == 'driver') {
                        return DriverHomeScreen();
                      }
                      return HomeScreen();
                    }
                    return Scaffold(
                      body: Center(
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
                      ),
                    );
                  },
                )
              : Scaffold(
                  body: Center(
                    child: CupertinoActivityIndicator(
                      color: ColorStyle.colorPrimary,
                    ),
                  ),
                )
          : const WelcomeScreen(),
    );
  }
}
