import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:note_taker/models/models.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

class Utils {
  static String generateId() {
    const uuid = Uuid();
    String id = uuid.v4();
    return id.substring(0, 20);
  }

  static String generateUserId(String name) {
    List<String> splitName = name.toLowerCase().split(' ');
    String nameId = '';
    for(String nameStr in splitName){
      nameId += '$nameStr.';
    }
    nameId += generateId().substring(0,5);
    return nameId;
  }

  static String generateNoteId() {
    return "n-${generateId()}";
  }

  static String generateCategoryId() {
    return "c-${generateId()}";
  }

  static String generateTodoId() {
    return "t-${generateId()}";
  }

  static String generateSubtaskId(){
    return "s-${generateId()}";
  }

  static double textHeight(
      String text, TextStyle style, int maxLines, BuildContext context) {
    if (text.isEmpty) return 0.0;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
      textAlign: TextAlign.start,
      strutStyle: const StrutStyle(forceStrutHeight: true),
      textDirection: ui.TextDirection.ltr,
      maxLines: maxLines,
    )..layout(minWidth: 0, maxWidth: (MediaQuery.of(context).size.width));
    // final countLines = (textPainter.width / (MediaQuery.of(context).size.width/2-100)).ceil();
    // final height = countLines * textPainter.size.height;
    final countLines =
        ((textPainter.size.width) / (MediaQuery.of(context).size.width * 0.5))
            .ceil();
      // print("COUNT LINES: ${textPainter.height}\t ${countLines}");
    double height = countLines * textPainter.height;
    final alphanumeric =
        RegExp(r'^[a-zA-Z0-9]+$', caseSensitive: false, multiLine: true);
    bool isEnglish = alphanumeric.hasMatch(text);
    if(countLines < 2) height+=5;
    // if (isEnglish) {
    //   return height + 10;
    // }
    return height;
  }

  static bool checkTheme() {
    return Get.isDarkMode ? true : false;
  }

  static double doneTodoCount = 0;
  static String clipText(String s) {
    String newStr = s;
    if (s.length > 18) {
      newStr = s.substring(0, 18) + '●●●';
    }
    return newStr;
  }

  static Color getCategoryColors(CATEGORY_COLORS color) {
    switch (color) {
      case CATEGORY_COLORS.teal:
        return Colors.teal;
      case CATEGORY_COLORS.orange:
        return Colors.orange;
      case CATEGORY_COLORS.green:
        return Colors.green;
      case CATEGORY_COLORS.blueGrey:
        return Colors.blueGrey;
      case CATEGORY_COLORS.blue:
        return Colors.blue;
      case CATEGORY_COLORS.brown:
        return Colors.brown;
      default:
        break;
    }
    return Colors.white;
  }

  static String getCategoryNames(DEFAULT_CAT_NAMES cat) {
    switch (cat) {
      case DEFAULT_CAT_NAMES.all:
        return "All";
      case DEFAULT_CAT_NAMES.personal:
        return "Personal";
      case DEFAULT_CAT_NAMES.work:
        return "Work";
      case DEFAULT_CAT_NAMES.entertainment:
        return "Entertainment";
      case DEFAULT_CAT_NAMES.study:
        return "Study";
      case DEFAULT_CAT_NAMES.poem:
        return "Poem";
      default:
        break;
    }
    return "";
  }

  static String getRepeatTypes(REPEAT_TYPES repeatType) {
    switch (repeatType) {
      case REPEAT_TYPES.once:
        return "Once";
      case REPEAT_TYPES.daily:
        return "Daily";
      case REPEAT_TYPES.monthly:
        return "Monthly";
      case REPEAT_TYPES.weekdays:
        return "Weekdays";
      case REPEAT_TYPES.weekends:
        return "Weekends";
      default:
        break;
    }
    return '';
  }

  static int getRepeatTypesIndex(String repeatType) {
    REPEAT_TYPES? type = REPEAT_TYPES.values.firstWhereOrNull(
        (type) => REPEAT_TYPES.values.byName(repeatType.toLowerCase()) == type);
    print(
        "ENUM VALUE FOR REPEAT TYPE: ${REPEAT_TYPES.values.byName(repeatType.toLowerCase())}");
    if (type == null) {
      return -1;
    } else {
      int index = REPEAT_TYPES.values.indexOf(type);
      return index;
    }
  }

  static String formatDate(DateTime date) {
    DateFormat dateFormat = DateFormat('dd MMMM yyyy');
    String formattedDate = dateFormat.format(date);
    return formattedDate;
  }

  static String getShortDate(String date) {
    List<String> dateList = date.split(' ');
    return "${dateList[0]} ${dateList[1]}";
  }

  static List<String> getNextSevenDays() {
    final _currentDate = DateTime.now();
    final List<String> dates = [];

    for (int i = 1; i <= 7; i++) {
      String formattedDate = formatDate(_currentDate.add(Duration(days: i)));
      dates.add(formattedDate);
    }
    return dates;
  }

  static String formatTime(DateTime time) {
    final format = DateFormat('hh : mm a');
    String formattedTime = format.format(time);
    return formattedTime;
  }

  static DateTime getTime(String time){
    final format = DateFormat('hh : mm a');
    DateTime formattedTime = format.parseStrict(time);
    return formattedTime;
  }

  static bool checkWeekday(DateTime date) {
    int weekday = date.weekday;
    if (weekday < 6) {
      return true;
    } else {
      return false;
    }
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  static Future<bool> checkInternetConnection(BuildContext context) async {
    ConnectivityResult result;
    final Connectivity _connectivity = Connectivity();
    bool _return = true;

    try {
      result = await _connectivity.checkConnectivity();
      switch (result) {
        case ConnectivityResult.none:
          _return = false;
          break;
        case ConnectivityResult.wifi:
          break;
        case ConnectivityResult.mobile:
          break;
        case ConnectivityResult.bluetooth:
          break;
        case ConnectivityResult.ethernet:
          break;
      }
    } on PlatformException catch (e) {
      print(e.toString());
    }
    return _return;
  }
}
