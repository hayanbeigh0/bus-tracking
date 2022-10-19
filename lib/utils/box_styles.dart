import 'package:flutter/material.dart';

class BoxStyles {
  static final primaryContainerDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(6.0),
    gradient: const LinearGradient(
      begin: FractionalOffset.topCenter,
      end: FractionalOffset.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.transparent,
        Color.fromARGB(119, 215, 216, 246),
        Color.fromARGB(119, 215, 216, 246),
      ],
      stops: [
        0.0,
        0.06,
        0.06,
        1.0,
      ],
    ),
  );
  static const topBarContainerDecoration = BoxDecoration(
    color: Color.fromARGB(43, 82, 121, 247),
    borderRadius: BorderRadius.only(
      bottomLeft: Radius.circular(70),
      bottomRight: Radius.circular(70),
    ),
  );
}
