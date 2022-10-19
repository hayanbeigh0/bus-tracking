import 'package:flutter/material.dart';

class TextFormFieldContainer extends StatelessWidget {
  const TextFormFieldContainer({
    Key? key,
    required this.textForm,
    this.backgroundColor = const Color.fromARGB(255, 255, 255, 255),
    this.borderColor = const Color.fromARGB(255, 208, 207, 207),
    this.borderRadius = 5.0,
    this.overLappingIcon = const SizedBox(),
    this.padding = 14.0,
    this.height = 55,
    this.noTopLeftRadius = false,
    this.noTopRightRadius = false,
    this.noBottomLeftRadius = false,
    this.noBottomRightRadius = false,
  }) : super(key: key);

  final Widget textForm;
  final Widget overLappingIcon;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double padding;
  final double height;
  final bool noTopLeftRadius;
  final bool noTopRightRadius;
  final bool noBottomLeftRadius;
  final bool noBottomRightRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(!noBottomLeftRadius ? borderRadius : 0),
          bottomRight: Radius.circular(!noBottomRightRadius ? borderRadius : 0),
          topRight: Radius.circular(!noTopRightRadius ? borderRadius : 0),
          topLeft: Radius.circular(!noTopLeftRadius ? borderRadius : 0),
        ),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: padding,
        ),
        child: Center(
            child: Stack(
          children: [
            textForm,
            Positioned(right: 0, child: overLappingIcon),
          ],
        )),
      ),
    );
  }
}
