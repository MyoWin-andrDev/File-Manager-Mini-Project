import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(){
    return ThemeData.light().copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: Colors.indigoAccent
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: Colors.white
        )
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.indigo),
        contentTextStyle: TextStyle(color: Colors.indigoAccent)
      ),
      inputDecorationTheme: InputDecorationThemeData(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigoAccent)
        ),
      ),
    );
  }
}
