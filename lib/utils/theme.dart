import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    foregroundColor: Colors.white,
  ),
  textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.teal,
  scaffoldBackgroundColor: Colors.grey[900],
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Colors.white,
  ),
  textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
);
