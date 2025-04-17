import 'package:flutter/material.dart';

class TTextTheme{
  TTextTheme._();
  static TextTheme darkText=TextTheme(
    //headline
    headlineLarge: const TextStyle().copyWith(fontSize: 34,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.white),
    headlineMedium: const TextStyle().copyWith(fontSize: 24,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.white),
    headlineSmall: const TextStyle().copyWith(fontSize: 18,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.white),
    //title
    titleLarge: const TextStyle().copyWith(fontSize: 16,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.white),
    titleMedium: const TextStyle().copyWith(fontSize: 16,fontWeight: FontWeight.w500,fontFamily: 'Poppins',color: Colors.white),
    titleSmall: const TextStyle().copyWith(fontSize: 16,fontWeight: FontWeight.w400,fontFamily: 'Poppins',color: Colors.white),
    //body
    bodyLarge: const TextStyle().copyWith(fontSize: 14,fontWeight: FontWeight.w500,fontFamily: 'Poppins',color: Colors.white),
    bodyMedium: const TextStyle().copyWith(fontSize: 14,fontWeight: FontWeight.normal,fontFamily: 'Poppins',color: Colors.white),
    bodySmall: const TextStyle().copyWith(fontSize: 14,fontWeight: FontWeight.w500,fontFamily: 'Poppins',color: Colors.white.withOpacity(0.5)),
    //label
    labelLarge: const TextStyle().copyWith(fontSize: 12,fontWeight: FontWeight.normal,fontFamily: 'Poppins',color: Colors.white),
    labelMedium: const TextStyle().copyWith(fontSize: 12,fontWeight: FontWeight.normal,fontFamily: 'Poppins',color: Colors.white),
  );
  static TextTheme lightText=TextTheme(
    //headline
    headlineLarge: const TextStyle().copyWith(fontSize: 34,fontWeight: FontWeight.bold,fontFamily: 'Poppins',color: Colors.black),
    headlineMedium: const TextStyle().copyWith(fontSize: 24,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.black),
    headlineSmall: const TextStyle().copyWith(fontSize: 18,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.black),
    //title
    titleLarge: const TextStyle().copyWith(fontSize: 16,fontWeight: FontWeight.w600,fontFamily: 'Poppins',color: Colors.black),
    titleMedium: const TextStyle().copyWith(fontSize: 16,fontWeight: FontWeight.w500,fontFamily: 'Poppins',color: Colors.black),
    titleSmall: const TextStyle().copyWith(fontSize: 16,fontWeight: FontWeight.w400,fontFamily: 'Poppins',color: Colors.black),
    //body
    bodyLarge: const TextStyle().copyWith(fontSize: 14,fontWeight: FontWeight.w500,fontFamily: 'Poppins',color: Colors.black),
    bodyMedium: const TextStyle().copyWith(fontSize: 14,fontWeight: FontWeight.normal,fontFamily: 'Poppins',color: Colors.black),
    bodySmall: const TextStyle().copyWith(fontSize: 14,fontWeight: FontWeight.w500,fontFamily: 'Poppins',color: Colors.black.withOpacity(0.5)),
    //label
    labelLarge: const TextStyle().copyWith(fontSize: 12,fontWeight: FontWeight.normal,fontFamily: 'Poppins',color: Colors.black),
    labelMedium: const TextStyle().copyWith(fontSize: 12,fontWeight: FontWeight.normal,fontFamily: 'Poppins',color: Colors.black),
  );
}