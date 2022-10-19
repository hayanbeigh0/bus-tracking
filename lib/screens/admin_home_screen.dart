import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iust_bus_tracking/screens/welcome.dart';
import 'package:iust_bus_tracking/utils/color.dart';
import 'package:iust_bus_tracking/widgets/text_form_field_container.dart';

class AdminHomeScreen extends StatefulWidget {
  AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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

  String userType = 'loading';
  @override
  Widget build(BuildContext context) {
    if (userType == 'admin') {
      return FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('admin')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CupertinoActivityIndicator(
                  color: ColorStyle.progressIndicatorColor,
                ),
              ),
            );
          }
          if (snapshots.hasError) {
            return Scaffold(
              body: Center(
                child: const Text("You are not an Admin!"),
              ),
            );
          }

          if (snapshots.hasData && !snapshots.data!.exists) {
            return Scaffold(
              body: const Center(
                child: Text("Document does not exist"),
              ),
            );
          }
          if (snapshots.connectionState == ConnectionState.done) {
            return Scaffold(
              body: CreateNotifications(),
            );
          }
          return Scaffold(
            body: Container(
              child: Column(
                children: [
                  Text(
                    ('Create a Notification'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else if (userType == 'driver' || userType == 'user') {
      FirebaseAuth.instance.signOut();
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You are not an Admin!'),
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

class CreateNotifications extends StatefulWidget {
  CreateNotifications({super.key});

  @override
  State<CreateNotifications> createState() => _CreateNotificationsState();
}

class _CreateNotificationsState extends State<CreateNotifications> {
  final TextEditingController notificationController = TextEditingController();

  bool showLoadingButton = false;

  bool disableButtonClick = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: ColorStyle.colorPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
          ),
          margin: EdgeInsets.all(0),
          child: SafeArea(
            child: Container(
              margin: EdgeInsets.only(
                top: 20.0,
                bottom: 30.0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 10.0,
              ),
              width: double.infinity,
              child: Text(
                'ADMIN PANEL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 255, 255),
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 30,
        ),
        Container(
          padding: EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Create a Notification',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              TextFormFieldContainer(
                padding: 10,
                height: 100,
                textForm: TextField(
                  textInputAction: TextInputAction.done,
                  controller: notificationController,
                  maxLines: 15,
                  decoration: InputDecoration.collapsed(
                    hintText: "Enter notification text here",
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: disableButtonClick
                      ? null
                      : () async {
                          if (notificationController.text.isEmpty) {
                            return;
                          }
                          setState(() {
                            disableButtonClick = true;
                            showLoadingButton = true;
                          });
                          await FirebaseFirestore.instance
                              .collection('notifications')
                              .add({
                                'notification': notificationController.text,
                                'timeStamp': FieldValue.serverTimestamp()
                              })
                              .then((value) => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      content: Text(
                                          'Notification created successfully'),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Ok'),
                                        ),
                                      ],
                                    ),
                                  ))
                              .onError((error, stackTrace) {
                                setState(() {
                                  disableButtonClick = false;
                                });
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: Text(error.toString()),
                                    actions: [
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('Ok'),
                                      ),
                                    ],
                                  ),
                                );
                                return showError();
                              });
                          ;
                          notificationController.text = '';
                          setState(() {
                            disableButtonClick = false;
                            showLoadingButton = false;
                          });
                        },
                  child: !showLoadingButton
                      ? Text(
                          'Create Notification',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )
                      : CupertinoActivityIndicator(
                          color: Colors.white,
                        ),
                ),
              ),
              SizedBox(
                height: 40,
              ),
              TextButton(
                onPressed: () {
                  _signOut();
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => const WelcomeScreen(),
                  ));
                },
                child: Text(
                  'Logout',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  showError() {}
}
