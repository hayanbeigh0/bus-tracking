import 'package:flutter/material.dart';
import 'package:iust_bus_tracking/screens/authentication_screens/login_screens/admin_login.dart';

import '../../../screens/authentication_screens/login_screens/driver_login.dart';
import '../../../screens/authentication_screens/login_screens/student_login.dart';
import '../../../widgets/text_form_field_container.dart';

class LoginOptionsScreen extends StatefulWidget {
  LoginOptionsScreen({Key? key}) : super(key: key);

  @override
  State<LoginOptionsScreen> createState() => _LoginOptionsScreenState();
}

class _LoginOptionsScreenState extends State<LoginOptionsScreen> {
  String loginType = 'Student Login';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 60,
                width: 190,
                child: TextFormFieldContainer(
                  noTopRightRadius: true,
                  noBottomRightRadius: true,
                  borderRadius: 12,
                  padding: 0,
                  textForm: DropdownButtonFormField(
                    iconEnabledColor: Colors.transparent,
                    iconSize: 0,
                    value: 'Student Login',
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.keyboard_arrow_down,
                      ),
                      labelStyle: TextStyle(
                        color: Color.fromARGB(255, 111, 111, 112),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                    ),
                    items: ['Driver Login', 'Student Login', 'Admin Login']
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        loginType = value.toString();
                      });
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    width: double.infinity,
                    child: Image.asset(
                      "asset/iust-logo.png",
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Container(
                    width: double.infinity,
                    height: 55,
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (loginType == 'Driver Login') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DriverLoginScreen(),
                            ),
                          );
                        } else if (loginType == 'Admin Login') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AdminLogin(),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StudentLoginScreen(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        loginType,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
