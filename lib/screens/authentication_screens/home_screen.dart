import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iust_bus_tracking/screens/bottom_navigation/notifications.dart';
import 'package:iust_bus_tracking/screens/welcome.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import '/screens/bottom_navigation/google_map_view.dart';
import '/screens/bottom_navigation/profile.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../models/driver_location.dart';
import '../../models/user_location.dart';
import '../../provider/driver_location.dart';
import '../../provider/user_location.dart';
import '../../services/location_services.dart';
import '../../utils/color.dart';
import '/screens/bottom_navigation/dashboard.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({
    super.key,
    this.isGuest = false,
  });
  bool isGuest;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userType = 'loading';
  double latitude = 0.0;
  double longitude = 0.0;
  late double pickedLongitude;
  late double pickedLatitude;
  int _selectedIndex = 0;
  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser != null) {
      checkUserType();
    } else {
      setState(() {
        userType = 'null';
      });
    }
    getBUSLocation();
    super.initState();
  }

  getBUSLocation() async {
    await connectAndListen();
    getBusLiveLocation();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static final List<Widget> _widgetOptions = <Widget>[
    const DashboardScreen(),
    const MapSample(),
    Notifications(),
    ProfileScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    if (userType == 'user' || FirebaseAuth.instance.currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Maps',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: ColorStyle.colorPrimary,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
        ),
      );
    } else if (userType == 'admin' || userType == 'driver') {
      FirebaseAuth.instance.signOut();
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You are not registered as a Student!'),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => WelcomeScreen(),
                    ),
                    (route) => false,
                  );
                },
                child: Text(
                  'Go back',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (userType == 'loading') {
      return Scaffold(
        body: Center(
          child: CupertinoActivityIndicator(
            color: Colors.black,
            radius: 20,
          ),
        ),
      );
    }
    return Scaffold(
      body: Center(
        child: Text('Please wait...'),
      ),
    );
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
}
