import 'package:flutter/material.dart';

class TBottomSheetThemeData {
  TBottomSheetThemeData._(); // Private constructor to prevent instantiation

  static  BottomSheetThemeData lightBottomSheetTheme = BottomSheetThemeData(
    modalElevation: 0,
    modalBackgroundColor: Colors.white.withOpacity(0.8),
    shape:  RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    showDragHandle: true,
    surfaceTintColor: Colors.transparent,
  );

  static  BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    modalElevation: 0,
    modalBackgroundColor: Colors.black.withOpacity(0.8),
    shape:  RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    showDragHandle: true,
    surfaceTintColor: Colors.transparent,
  );
}
