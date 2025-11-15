import 'package:flutter/material.dart';
import '../utils/constant/app_colors.dart';

class CustomAppTheme {
  static const primaryColor = AppColors.primaryColor;
  static const secondaryColor = AppColors.secondaryColor;

  // >>> ================================
  // LIGHT THEME
  // <<< ================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(primary: primaryColor, secondary: secondaryColor, brightness: Brightness.light,),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(backgroundColor: primaryColor, foregroundColor: Colors.white, elevation: 3,),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xffE3F2FD),),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: primaryColor, selectedItemColor: Colors.white, unselectedItemColor: Colors.white70,),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)),), padding: EdgeInsets.symmetric(vertical: 14),),),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: const Color(0xffE3F2FD), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: primaryColor, width: 2), borderRadius: BorderRadius.circular(10),), enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: secondaryColor), borderRadius: BorderRadius.circular(10),),),
  );

  // >>> ================================
  // DARK THEME (Night Mode)
  // <<< ================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(primary: primaryColor, secondary: secondaryColor, brightness: Brightness.dark,),
    scaffoldBackgroundColor: Color(0xff121212),
    appBarTheme: const AppBarTheme(backgroundColor: Color(0xff0A0A0A), foregroundColor: Colors.white, elevation: 2,),
    drawerTheme: const DrawerThemeData(backgroundColor: Color(0xff1E1E1E),),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(backgroundColor: Color(0xff0A0A0A), selectedItemColor: secondaryColor, unselectedItemColor: Colors.white60,),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10)),), padding: EdgeInsets.symmetric(vertical: 14),),),
    inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: Color(0xff1E1E1E), focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: secondaryColor, width: 2), borderRadius: BorderRadius.circular(10),), enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white30), borderRadius: BorderRadius.circular(10),), labelStyle: TextStyle(color: secondaryColor), hintStyle: TextStyle(color: Colors.white60),),
  );
}
