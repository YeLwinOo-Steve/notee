import 'package:get/get.dart';
import 'package:note_taker/shared_data/shared_data.dart';

class AccountController extends GetxController {
  set setLoggedIn(bool loggedIn) => SharedData.setLoggedIn(loggedIn);
  set setDarkTheme(bool isDarkTheme) => SharedData.setDarkTheme(isDarkTheme);
  get isLoggedIn async => await SharedData.isLoggedIn();
  get isDarkTheme async => await SharedData.isDarkTheme();
}
