import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../utils/color.dart';

class Notifications extends StatelessWidget {
  Notifications({super.key});
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('notifications').snapshots();
  final Color color = ColorStyle.colorPrimary;
  List<dynamic> list = [];
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
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
                'NOTIFICATIONS',
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
        StreamBuilder<QuerySnapshot>(
          stream: _usersStream,
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return Center(child: const Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: const Text("Loading"));
            }
            list = snapshot.data!.docs;
            list.sort(
              (a, b) => a['timeStamp'].compareTo(b['timeStamp']),
            );
            list = list.reversed.toList();
            return list.length == 0
                ? Expanded(
                    child: Center(
                      child: Text(
                        'No Notifications!',
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 20),
                      itemCount: list.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          elevation: 0,
                          margin:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: BorderSide(
                              color: color,
                            ),
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: double.infinity,
                                  color: color,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      list[index]['notification'],
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
          },
        )
      ],
    );
  }
}
