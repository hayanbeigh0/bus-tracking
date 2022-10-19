import 'package:flutter/material.dart';
import '/screens/authentication_screens/home_screen.dart';
import '/utils/color.dart';

import './authentication_screens/login_screens/login_options.dart';
import './authentication_screens/registration_screens/registrations_options.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        primary: true,
        backgroundColor: ColorStyle.colorPrimary,
        title: const Text('Welcome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              width: double.infinity,
              child: Text(
                'IUST BUS TRACKING',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: ColorStyle.colorPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LoginOptionsScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 70,
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: ColorStyle.colorPrimary,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => RegistrationOptionsScreen(),
                    ),
                  );
                },
                child: Text(
                  'Register',
                  style: TextStyle(
                    fontSize: 15,
                    color: ColorStyle.colorPrimary,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    isGuest: true,
                  ),
                ));
              },
              child: Text(
                'Skip →',
                style: TextStyle(
                  fontSize: 15,
                  decoration: TextDecoration.underline,
                  color: ColorStyle.colorPrimary,
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
