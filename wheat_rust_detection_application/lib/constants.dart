import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static Color primary = hexToColor('50A865');
  static Color secondary = hexToColor('40744D');
  static Color yellow = hexToColor('FFD700');
}

Color hexToColor(String hex) {
  hex = hex.replaceAll("#", "");
  if (hex.length == 6) {
    hex = "FF$hex"; // Add alpha value if missing
  }
  return Color(int.parse(hex, radix: 16));
}
