import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor customSwatch = MaterialColor(
    0xFF0e386f,
    <int, Color>{
      50: Color(0xff0d3264), //10%
      100: Color(0xff0b2d59), //20%
      200: Color(0xff0a274e), //30%
      300: Color(0xff082243), //40%
      400: Color(0xff071c38), //50%
      500: Color(0xff06162c), //60%
      600: Color(0xff041121), //70%
      700: Color(0xff030b16), //80%
      800: Color(0xff01060b), //90%
      900: Color(0xff000000), //100%
    },
  );

  static const MaterialColor customSwatchDark = MaterialColor(
    0xFFABCDEF, // Substitua pelo valor de cor desejado para o modo escuro
    <int, Color>{
      50: Color(0xff123456), //10%
      100: Color(0xff234567), //20%
      200: Color(0xff345678), //30%
      300: Color(0xff456789), //40%
      400: Color(0xff56789a), //50%
      500: Color(0xff6789ab), //60%
      600: Color(0xff789abc), //70%
      700: Color(0xff89abcd), //80%
      800: Color(0xff9abcde), //90%
      900: Color(0xffabcdef), //100%
    },
  );
}
