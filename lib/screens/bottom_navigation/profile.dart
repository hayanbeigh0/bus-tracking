import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '/utils/color.dart';
import '/widgets/text_form_field_container.dart';

import '../welcome.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController busNumberController = TextEditingController();
  final TextEditingController registrationNumberController =
      TextEditingController();

  final TextEditingController emailController = TextEditingController();

  bool editFirstName = false;
  bool showProgressIndicator = false;

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
                'PROFILE',
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
        FirebaseAuth.instance.currentUser != null
            ? StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshots,
                ) {
                  if (snapshots.hasError) {
                    return const Text("Something went wrong");
                  }

                  if (snapshots.hasData && !snapshots.data!.exists) {
                    return const Text("Document does not exist");
                  }
                  if (snapshots.hasData) {
                    Map<String, dynamic> data =
                        snapshots.data!.data() as Map<String, dynamic>;
                    emailController.text = data['email'];
                    firstNameController.text = data['firstName'];
                    lastNameController.text = data['lastName'];
                    busNumberController.text = data['busNumber'];
                    registrationNumberController.text =
                        data['studentRegistration'];
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 25,
                            ),
                            CircleAvatar(
                              radius: 50,
                              child: Image.asset("asset/profile-icon.png"),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Transform.translate(
                              offset: const Offset(22, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${firstNameController.text} ${lastNameController.text}',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                'Edit Name',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 24,
                                                child: IconButton(
                                                  onPressed: () =>
                                                      Navigator.of(context)
                                                          .pop(),
                                                  icon: const Icon(
                                                    Icons.close,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: editNameWidget(context),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: ColorStyle.colorPrimary,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            TextFormFieldContainer(
                              borderColor: ColorStyle.colorPrimaryExtraLight,
                              borderRadius: 10,
                              textForm: TextFormField(
                                style: TextStyle(
                                  color: ColorStyle.colorProfileText,
                                ),
                                controller: emailController,
                                autovalidateMode: AutovalidateMode.always,
                                decoration: InputDecoration(
                                  prefix: Text(
                                    'Email: ',
                                    style: TextStyle(
                                      color: ColorStyle.colorProfileText,
                                    ),
                                  ),
                                  fillColor: ColorStyle.colorProfileText,
                                  enabled: false,
                                  border: InputBorder.none,
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'\s'),
                                  ),
                                ],
                                cursorHeight: 25,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormFieldContainer(
                              borderColor: ColorStyle.colorPrimaryExtraLight,
                              borderRadius: 10,
                              textForm: TextFormField(
                                style: TextStyle(
                                  color: ColorStyle.colorProfileText,
                                ),
                                controller: registrationNumberController,
                                autovalidateMode: AutovalidateMode.always,
                                decoration: InputDecoration(
                                  prefix: Text(
                                    'Registration Number: ',
                                    style: TextStyle(
                                      color: ColorStyle.colorProfileText,
                                    ),
                                  ),
                                  fillColor: ColorStyle.colorProfileText,
                                  enabled: false,
                                  border: InputBorder.none,
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'\s'),
                                  ),
                                ],
                                cursorHeight: 25,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormFieldContainer(
                              borderColor: ColorStyle.colorPrimaryExtraLight,
                              overLappingIcon: IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Edit Bus Number',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 24,
                                            child: IconButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              icon: const Icon(
                                                Icons.close,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      content: editBusNumberWidget(context),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: ColorStyle.colorPrimary,
                                ),
                              ),
                              borderRadius: 10,
                              textForm: TextFormField(
                                style: TextStyle(
                                  color: ColorStyle.colorProfileText,
                                ),
                                controller: busNumberController,
                                autovalidateMode: AutovalidateMode.always,
                                decoration: InputDecoration(
                                  prefix: Text(
                                    'Bus Number: ',
                                    style: TextStyle(
                                      color: ColorStyle.colorProfileText,
                                    ),
                                  ),
                                  fillColor: ColorStyle.colorProfileText,
                                  enabled: false,
                                  border: InputBorder.none,
                                ),
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.deny(
                                    RegExp(r'\s'),
                                  ),
                                ],
                                cursorHeight: 25,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(
                              height: 45,
                            ),
                            SizedBox(
                              height: 55,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showProgressIndicator = true;
                                  });
                                  _signOut();
                                  Navigator.of(context)
                                      .pushReplacement(MaterialPageRoute(
                                    builder: (context) => const WelcomeScreen(),
                                  ));
                                },
                                child: showProgressIndicator
                                    ? const CupertinoActivityIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        'Logout',
                                        style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          fontSize: 15,
                                          color: Colors.red,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Center(child: SpinKitCircle(
                    itemBuilder: (BuildContext context, int index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: index.isEven
                              ? ColorStyle.progressIndicatorColor
                              : ColorStyle.progressIndicatorColor,
                        ),
                      );
                    },
                  ));
                })
            : Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Please Login to view this page!',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      TextButton(
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Go to Login!',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ],
    );
  }

  Column editBusNumberWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormFieldContainer(
          borderRadius: 10,
          textForm: TextFormField(
            style: TextStyle(
              color: ColorStyle.colorProfileText,
            ),
            controller: busNumberController,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              label: const Text('Bus Number'),
              fillColor: ColorStyle.colorProfileText,
              enabled: true,
              border: InputBorder.none,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
              ),
            ],
            cursorHeight: 25,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorStyle.colorPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 10,
            ),
          ),
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('user')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update(
              {
                'busNumber': busNumberController.text,
              },
            );
            // setState(() {
            busNumberController.text;
            // });
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        )
      ],
    );
  }

  Column editNameWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextFormFieldContainer(
          borderRadius: 10,
          textForm: TextFormField(
            style: TextStyle(
              color: ColorStyle.colorProfileText,
            ),
            controller: firstNameController,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              label: const Text('First Name'),
              fillColor: ColorStyle.colorProfileText,
              enabled: true,
              border: InputBorder.none,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
              ),
            ],
            cursorHeight: 25,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        TextFormFieldContainer(
          borderRadius: 10,
          textForm: TextFormField(
            style: TextStyle(
              color: ColorStyle.colorProfileText,
            ),
            controller: lastNameController,
            autovalidateMode: AutovalidateMode.always,
            decoration: InputDecoration(
              label: const Text('Last Name'),
              fillColor: ColorStyle.colorProfileText,
              enabled: true,
              border: InputBorder.none,
            ),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.deny(
                RegExp(r'\s'),
              ),
            ],
            cursorHeight: 25,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 33, 82, 243),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 10,
            ),
          ),
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('user')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update(
              {
                'firstName': firstNameController.text,
                'lastName': lastNameController.text,
              },
            );
            // setState(() {
            firstNameController.text;
            lastNameController.text;
            // });
            Navigator.of(context).pop();
          },
          child: const Text(
            'Save',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void showEditNameDialog() {}
}
