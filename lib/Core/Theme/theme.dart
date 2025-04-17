import 'package:flutter/material.dart';

import 'custom_themes/appBarTheme.dart';
import 'custom_themes/bottomSheetData.dart';
import 'custom_themes/checkBoxTheme.dart';
import 'custom_themes/chipTheme.dart';
import 'custom_themes/elevatedButtonTheme.dart';
import 'custom_themes/outLinedButtonTheme.dart';
import 'custom_themes/textFormFieldTheme.dart';
import 'custom_themes/textTheme.dart';

class TAppTheme {
  TAppTheme._();
  
  static  ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: Colors.blue,

    textTheme: TTextTheme.lightText,
    chipTheme: TChipTheme.lightChipTheme,

    scaffoldBackgroundColor: Colors.white,
    appBarTheme: TAppBarTheme.lightAppBarTheme,

    checkboxTheme: TCheckboxTheme.lightCheckboxTheme,
    bottomSheetTheme: TBottomSheetThemeData.lightBottomSheetTheme,

    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButton,
    outlinedButtonTheme: ToutlinedButtonTheme.lightOutlinedButtonTheme,

    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );

  static  ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: Colors.blue,

    textTheme: TTextTheme.darkText,
    chipTheme: TChipTheme.darkChipTheme,

    scaffoldBackgroundColor: Colors.black,
    appBarTheme: TAppBarTheme.darkAppBarTheme,

    checkboxTheme: TCheckboxTheme.darkCheckboxTheme,

    bottomSheetTheme: TBottomSheetThemeData.darkBottomSheetTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButton,
    outlinedButtonTheme: ToutlinedButtonTheme.darkOutlinedButtonTheme,

    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  );
}
