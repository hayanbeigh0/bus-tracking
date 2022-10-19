import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../home_screen.dart';
import '../../login_screens/student_login.dart';

class SetPassword extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String studentRegistration;
  final String busNumber;
  final double pickedLongitude;
  final double pickedLatitude;

  SetPassword({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.studentRegistration,
    required this.busNumber,
    required this.pickedLongitude,
    required this.pickedLatitude,
  });

  @override
  State<SetPassword> createState() => _SetPasswordState();
}

class _SetPasswordState extends State<SetPassword> {
  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool showProgressIndicator = false;
  bool disableButtonClick = false;

  var db = FirebaseFirestore.instance;

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
                                  .collection('user')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .set({
                                'userType': 'student',
                                'firstName': widget.firstName,
                                'lastName': widget.lastName,
                                'email': widget.email,
                                'studentRegistration':
                                    widget.studentRegistration,
                                'busNumber': widget.busNumber,
                                'pickedLatitude': widget.pickedLatitude,
                                'pickedLongitude': widget.pickedLongitude,
                                'userId':
                                    FirebaseAuth.instance.currentUser!.uid,
                              }).then(
                                (value) =>
                                    Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => HomeScreen(),
                                  ),
                                  (Route<dynamic> route) => false,
                                ),
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
