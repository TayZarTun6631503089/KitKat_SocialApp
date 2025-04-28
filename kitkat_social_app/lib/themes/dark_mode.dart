import 'package:flutter/material.dart';

const Color kPrimaryColor = Color(0xFF4EB6E9); // Main logo blue
const Color kAccentColor = Color(0xFF82FDFF); // Gradient highlight

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    primary: kPrimaryColor,
    secondary: kAccentColor,
    surface: Color(0xFF1A2330), // deep blue-gray for cards
    background: Color(0xFF101721), // almost black, with blue hint
    error: Color(0xFFEF4444),
    onPrimary: Colors.white, // white on blue buttons
    onSecondary: Colors.black87, // dark text on secondary
    onSurface: Color(0xFFCAEDFF), // very light blue text on dark
    onBackground: Color(0xFFCAEDFF), // very light blue text
    onError: Colors.white,
    tertiary: kAccentColor, // for chips/highlights
    inversePrimary: Color(0xFF133A50), // deep blue
  ),
  scaffoldBackgroundColor: Color(0xFF101721),
  appBarTheme: AppBarTheme(
    backgroundColor: kPrimaryColor,
    foregroundColor: Colors.white,
    elevation: 1,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    iconTheme: IconThemeData(color: kAccentColor),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: kAccentColor,
    foregroundColor: Color(0xFF18425D), // deep blue for icons
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: TextStyle(fontWeight: FontWeight.bold),
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      elevation: 2,
    ),
  ),
  cardTheme: CardTheme(
    color: Color(0xFF1A2330), // matches surface
    elevation: 3,
    shadowColor: kPrimaryColor.withOpacity(0.15),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
