import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../driver_home_screen.dart';
import '../../home_screen.dart';
import '../../login_screens/student_login.dart';

class DriverPasswordScreen extends StatefulWidget {
  DriverPasswordScreen({
    Key? key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.busRegistrationNumber,
    required this.busNumber,
  }) : super(key: key);
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String busRegistrationNumber;
  final String busNumber;

  @override
  State<DriverPasswordScreen> createState() => _DriverPasswordScreenState();
}

class _DriverPasswordScreenState extends State<DriverPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  var db = FirebaseFirestore.instance;
  bool showProgressIndicator = false;
  bool disableButtonClick = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: '*********',
                  ),
                  scrollPadding: const EdgeInsets.only(bottom: 40),
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Password',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                TextFormField(
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    hintText: '*********',
                  ),
                  scrollPadding: const EdgeInsets.only(bottom: 40),
                  controller: confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    onPressed: disableButtonClick
                        ? null
                        : () async {
                            setState(() {
                              disableButtonClick = true;
                              showProgressIndicator = true;
                            });
                            try {
                              await FirebaseAuth.instance
                                  .createUserWithEmailAndPassword(
                                email: widget.email,
                                password: confirmPasswordController.text,
                              );
                              await FirebaseFirestore.instance
                                  .collection('driver')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .set({
                                'userType': 'driver',
                                'firstName': widget.firstName,
                                'lastName': widget.lastName,
                                'email': widget.email,
                                'phone': widget.phoneNumber,
                                'busRegistrationNumber':
                                    widget.busRegistrationNumber,
                                'busNumber': widget.busNumber,
                                'userId':
                                    FirebaseAuth.instance.currentUser!.uid,
                              });
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => DriverHomeScreen(),
                                ),
                                (Route<dynamic> route) => false,
                              );
                            } on FirebaseAuthException catch (e) {
                              setState(() {
                                showProgressIndicator = false;
                                disableButtonClick = false;
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content:
                                        Text(getMessageFromErrorCode(e.code)),
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
                              });
                            }
                            setState(() {
                              disableButtonClick = false;
                            });
                          },
                    child: showProgressIndicator
                        ? const CupertinoActivityIndicator(
                            animating: true,
                            color: Colors.white,
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
