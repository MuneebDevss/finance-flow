import 'package:flutter/material.dart';

class ColorFormats{
  static const Map<String, Color> colorNameMap = {
    'red': Colors.red,
    'pink': Colors.pink,
    'purple': Colors.purple,
    'deepPurple': Colors.deepPurple,
    'indigo': Colors.indigo,
    'blue': Colors.blue,
    'lightBlue': Colors.lightBlue,
    'cyan': Colors.cyan,
    'teal': Colors.teal,
    'green': Colors.green,
    'lightGreen': Colors.lightGreen,
    'lime': Colors.lime,
    'yellow': Colors.yellow,
    'amber': Colors.amber,
    'orange': Colors.orange,
    'deepOrange': Colors.deepOrange,
    'brown': Colors.brown,
    'grey': Colors.grey,
    'blueGrey': Colors.blueGrey,
    'black': Colors.black,
    'white': Colors.white,
    'silver': Colors.white,
    'redAccent': Colors.redAccent,
    'pinkAccent': Colors.pinkAccent,
    'purpleAccent': Colors.purpleAccent,
    'tealAccent': Colors.tealAccent,
    'limeAccent': Colors.limeAccent,
    'yellowAccent': Colors.yellowAccent,
    'orangeAccent': Colors.orangeAccent,
    'deepOrangeAccent': Colors.deepOrangeAccent,
  };


  static  String getColorString(Color color) {
    final match = colorNameMap.entries.firstWhere(
            (entry) => entry.value.value == color.value,
        );
    return match.key;
  }
  static Color? getColorByKey(String key)
  {
    return colorNameMap[key];
  }

}