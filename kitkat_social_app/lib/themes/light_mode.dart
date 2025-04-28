import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF4EB6E9); // Main logo blue
const Color kAccentColor = Color.fromARGB(
  255,
  180,
  249,
  251,
); // Gradient highlight

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    primary: kPrimaryColor,
    secondary: const Color.fromARGB(255, 196, 252, 253),
    surface: Color(0xFFF8FBFF), // very light blue/white background
    background: Color(0xFFE6F7FD), // ultra-soft blue hint
    error: Color(0xFFEF4444),
    onPrimary: Colors.white, // contrast on primary (button text etc)
    onSecondary: Colors.black87, // dark text on secondary
    onSurface: Color(0xFF18425D), // deep blue for strong text
    onBackground: Color(0xFF18425D), // deep blue for default text
    onError: Colors.white,
    tertiary: const Color.fromARGB(
      255,
      204,
      245,
      246,
    ), // for chips or highlights
    inversePrimary: Color(0xFF258EB0), // deep blue (darker shade of primary)
  ),
  scaffoldBackgroundColor: Color(0xFFE6F7FD), // matches background
  appBarTheme: AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: kAccentColor,
    foregroundColor: Color(0xFF18425D),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      // Gradient hint: use both primary and accent in the gradient
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: TextStyle(fontWeight: FontWeight.bold),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 2,
    ),
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 3,
    shadowColor: kPrimaryColor.withOpacity(0.08),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
