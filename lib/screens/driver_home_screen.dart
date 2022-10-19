import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/provider/driver_location.dart';
import '/screens/welcome.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/utils/color.dart';

late int busNum;
late String phoneNumber;
late String driverName;

class DriverHomeScreen extends StatefulWidget with WidgetsBindingObserver {
  DriverHomeScreen({Key? key}) : super(key: key);

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  String buttonText = 'Start Journey';
  bool activeJourney = false;
  bool showProgressIndicator = false;
  String userType = 'loading';
  @override
  void initState() {
    if (FirebaseAuth.instance.currentUser != null) {
      checkUserType();
    } else {
      setState(() {
        userType = 'null';
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (userType == 'driver') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Driver Panel'),
          actions: [
            IconButton(
              onPressed: () {
                _signOut();
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => const WelcomeScreen(),
                ));
              },
              icon: Icon(
                Icons.logout,
              ),
            ),
          ],
        ),
        body: FutureBuilder(
          future: FirebaseFirestore.instance
              .collection('driver')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get(),
          builder: (BuildContext context,
              AsyncSnapshot<DocumentSnapshot> snapshots) {
            if (snapshots.hasError) {
              return const Text("Something went wrong");
            }

            if (snapshots.hasData && !snapshots.data!.exists) {
              return const Center(
                child: Text("Document does not exist"),
              );
            }

            if (snapshots.connectionState == ConnectionState.done) {
              Map<String, dynamic> data =
                  snapshots.data!.data() as Map<String, dynamic>;
              busNum = int.parse(data['busNumber']);
              driverName = '${data['firstName']} ${data['lastName']}';
              phoneNumber = data['phone'];
              return StartStopRoute();
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
      );
    } else if (userType == 'admin' || userType == 'user') {
      FirebaseAuth.instance.signOut();
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You are not registered as a Driver!'),
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

  void _signOut() async {
    disconnectAndStopSharingDriverLocation(busNum);
    await FirebaseAuth.instance.signOut();
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

class StartStopRoute extends StatefulWidget {
  StartStopRoute({super.key});

  @override
  State<StartStopRoute> createState() => _StartStopRouteState();
}

class _StartStopRouteState extends State<StartStopRoute> {
  String buttonText = 'Start Journey';

  bool activeJourney = false;
  bool disableButton = false;
  bool showProgressIndicator = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 200,
              width: 200,
              child: MaterialButton(
                disabledColor: activeJourney ? Colors.green : Colors.grey,
                shape: CircleBorder(
                  side: BorderSide(
                    width: 2,
                    color: activeJourney ? Colors.green : Colors.grey,
                    style: BorderStyle.solid,
                  ),
                ),
                splashColor: Colors.white,
                color: activeJourney ? Colors.green : Colors.grey,
                elevation: 10,
                onPressed: disableButton
                    ? null
                    : () async {
                        setState(() {
                          disableButton = true;
                          showProgressIndicator = true;
                        });
                        if (buttonText == 'Start Journey') {
                          await connectAndSendLocation(
                            busNum,
                            driverName,
                            phoneNumber,
                          );
                          print('started');
                          setState(() {
                            disableButton = false;
                            activeJourney = true;
                            showProgressIndicator = false;
                            buttonText = 'Stop Journey';
                          });
                        } else if (buttonText == 'Stop Journey') {
                          await disconnectAndStopSharingDriverLocation(busNum);

                          setState(() {
                            disableButton = false;
                            activeJourney = false;
                            showProgressIndicator = false;
                            buttonText = 'Start Journey';
                          });
                          print('ended');
                        }
                      },
                child: showProgressIndicator
                    ? CupertinoActivityIndicator(
                        color: Colors.white,
                        radius: 15,
                      )
                    : Text(
                        buttonText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
