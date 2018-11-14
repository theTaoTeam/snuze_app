import 'package:flutter/material.dart';

final Color primaryColor = Colors.white;

ThemeData buildLightTheme() {
  return ThemeData(
    primaryColor: Color(0xFFFE2562), //pink
    accentColor: Color(0xFFA1A1A1) ,//dark grey
    disabledColor: Color(0xFFDFDFDF), //light grey
    toggleableActiveColor: Color(0xFFFE2562), //pink
    highlightColor: Color(0xFFFFFFFF), //white
    backgroundColor: Color(0xFFFFFFFF), //white
    dividerColor: Color(0xFF434343), //black
    brightness: Brightness.light,
    
  );
}

ThemeData buildDarkTheme() {
  return ThemeData(
    primaryColor: Color(0xFFFE2562), //pink
    accentColor: Color(0xFFA1A1A1), //light grey
    disabledColor: Color(0xFFDFDFDF) ,//dark grey
    toggleableActiveColor: Color(0xFFFE2562), //pink
    highlightColor: Color(0xFFFFFFFF), //white
    backgroundColor: Color(0xFF434343), //white
    dividerColor: Color(0xFFFFFFFF), //black
    // brightness: Brightness.light,
  );
}
