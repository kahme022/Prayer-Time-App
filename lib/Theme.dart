import 'package:flutter/material.dart';

class Colors {

  const Colors();

  static const Color tableText = const Color(0xFFFFFFFF);

}

class TextStyles {

  const TextStyles();

  static const TextStyle tableRowText = const TextStyle(
      color: Colors.tableText,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w300,
      fontSize: 24.0
  );

  static const TextStyle tableHeadingText = const TextStyle(
      color: Colors.tableText,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 24.0
  );

}