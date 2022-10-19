import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:iust_bus_tracking/screens/authentication_screens/login_screens/student_login.dart';
import 'package:iust_bus_tracking/utils/color.dart';

import '../../admin_home_screen.dart';

class AdminLogin extends StatefulWidget {
  AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  bool displayProgressIndicator = false;
  bool disableButtonClick = false;
  bool showProgressIndicator = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'you@example.com',
                    ),
                    textInputAction: TextInputAction.next,
                    scrollPadding: const EdgeInsets.only(bottom: 40),
                    controller: _emailController,
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
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
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: '********',
                    ),
                    textInputAction: TextInputAction.next,
                    scrollPadding: const EdgeInsets.only(bottom: 40),
                    controller: _passwordController,
                    obscureText: true,
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: 60,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: ColorStyle.colorPrimary,
                    disabledForegroundColor: ColorStyle.colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: disableButtonClick
                      ? null
                      : () async {
                          setState(() {
                            disableButtonClick = true;
                            displayProgressIndicator = true;
                          });
                          try {
                            await FirebaseAuth.instance
                                .signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            setState(() {
                              disableButtonClick = false;
                            });

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => AdminHomeScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
                          } on FirebaseAuthException catch (e) {
                            setState(() {
                              _emailController.text = '';
                              _passwordController.text = '';
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
                        },
                  child: displayProgressIndicator
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
        ),
      ),
    );
  }

  showError() {}
}
