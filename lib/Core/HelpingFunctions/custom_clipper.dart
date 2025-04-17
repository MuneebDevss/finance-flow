import 'package:flutter/material.dart';

class BottomShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var  path=Path();
    path.lineTo(0, size.height);
    final firstCurve=Offset(0, size.height-20);//controlling point
    final secondCurve=Offset(30, size.height-20);//point to reach
    path.quadraticBezierTo(firstCurve.dx, firstCurve.dy, secondCurve.dx, secondCurve.dy);
    final lastCurve1=Offset(30, size.height-20);
    final lastCurve2=Offset(size.width-30, size.height-20);
    path.quadraticBezierTo(lastCurve1.dx, lastCurve1.dy, lastCurve2.dx, lastCurve2.dy);
    final third1=Offset(size.width, size.height-20);
    final third2=Offset(size.width, size.height);
    path.quadraticBezierTo(third1.dx, third1.dy, third2.dx, third2.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}