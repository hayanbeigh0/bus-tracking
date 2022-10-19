import 'package:flutter/material.dart';

import '../../../widgets/text_form_field_container.dart';
import 'driver_registration/driver_registration.dart';
import 'student_registration/student_registration.dart';

class RegistrationOptionsScreen extends StatefulWidget {
  RegistrationOptionsScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationOptionsScreen> createState() =>
      _RegistrationOptionsScreenState();
}

class _RegistrationOptionsScreenState extends State<RegistrationOptionsScreen> {
  String registrationType = 'Student Registration';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
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
                    value: 'Student Registration',
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
                    items: ['Driver Registration', 'Student Registration']
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
                        registrationType = value.toString();
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
                        if (registrationType == 'Driver Registration') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DriverRegistrationScreen(),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => StudentRegistrationScreen(),
                            ),
                          );
                        }
                      },
                      child: Text(
                        registrationType,
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
