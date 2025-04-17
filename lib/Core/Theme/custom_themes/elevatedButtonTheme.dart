import 'package:flutter/material.dart';

class TElevatedButtonTheme
{
  TElevatedButtonTheme._();
  static ElevatedButtonThemeData lightElevatedButton =ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      side: const BorderSide(color: Colors.blue),
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
      elevation: 0,
      disabledForegroundColor: Colors.grey,
      disabledBackgroundColor: Colors.grey,
      padding: const EdgeInsets.symmetric(vertical: 18
      ),
      textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.white)
    )
  );
  static ElevatedButtonThemeData darkElevatedButton =ElevatedButtonThemeData(
  style: ElevatedButton.styleFrom(
  shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(14),
  ),
  side: const BorderSide(color: Colors.blue),
  backgroundColor: Colors.blue,
  foregroundColor: Colors.white,
  elevation: 0,
  disabledForegroundColor: Colors.grey,
  disabledBackgroundColor: Colors.grey,
  padding: const EdgeInsets.symmetric(vertical: 18
  ),
  textStyle: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.black)
  ));
}