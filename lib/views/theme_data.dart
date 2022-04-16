import 'package:flutter/material.dart';
import 'package:note_taker/components/components.dart';

final kLightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kPrimaryColor,
  scaffoldBackgroundColor: kPrimaryColor,
  backgroundColor: kPrimaryColor,
  chipTheme: const ChipThemeData(
    backgroundColor: kPrimaryColor,
    labelStyle: TextStyle(color: kTextColor),
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: kIconColor,
    selectionColor: Colors.teal.shade200,
    selectionHandleColor: Colors.teal.shade300,
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: kPrimaryColor,
  ),
  // timePickerTheme: kTimePickerTheme,
);

final kDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: kDarkPrimaryColor,
  scaffoldBackgroundColor: kDarkPrimaryColor,
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: kPrimaryColor,
    selectionColor: kPrimaryColor.withOpacity(0.5),
    selectionHandleColor: kTextColor,
  ),
  chipTheme: const ChipThemeData(
    backgroundColor: kDarkPrimaryColor,
    labelStyle: TextStyle(color: Colors.white),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.black,
  ),
  // timePickerTheme: kTimePickerTheme,
);

// final kTimePickerTheme = TimePickerThemeData(
//   backgroundColor: Colors.white,
//   hourMinuteShape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(8)),
//     side: BorderSide(color: kIconColor, width: 2),
//   ),
//   dayPeriodBorderSide: const BorderSide(color: kIconColor, width: 2),
//   dayPeriodColor: MaterialStateColor.resolveWith((states) =>
//       states.contains(MaterialState.selected)
//           ? kIconColor
//           : Colors.teal.shade100),
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(8)),
//     side: BorderSide(color: kIconColor, width: 2),
//   ),
//   dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
//       states.contains(MaterialState.selected)
//           ? Colors.teal.shade100
//           : kIconColor),
//   dayPeriodShape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(8)),
//     side: BorderSide(color: kIconColor, width: 2),
//   ),
//   hourMinuteColor: MaterialStateColor.resolveWith((states) =>
//       states.contains(MaterialState.selected)
//           ? kIconColor
//           : Colors.teal.shade100),
//   hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
//       states.contains(MaterialState.selected) ? Colors.white : kIconColor),
//   dialHandColor: Colors.teal.shade300,
//   dialBackgroundColor: Colors.teal,
//   hourMinuteTextStyle:
//       const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
//   dayPeriodTextStyle:
//       const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
//   helpTextStyle: const TextStyle(
//       fontSize: 16, fontWeight: FontWeight.bold, color: kTextColor),
//   inputDecorationTheme: const InputDecorationTheme(
//     border: InputBorder.none,
//     contentPadding: EdgeInsets.all(10),
//   ),
//   dialTextColor: MaterialStateColor.resolveWith((states) =>
//       states.contains(MaterialState.selected) ? Colors.white : Colors.white),
//   entryModeIconColor: kIconColor,
// );

