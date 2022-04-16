import 'package:shared_preferences/shared_preferences.dart';
import 'package:note_taker/models/models.dart';

class SharedData {
  static late SharedPreferences prefs;

  static void setLoggedIn(bool loggedIn) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setBool("log_in", loggedIn);
    print("SET LOG IN $loggedIn");
  }

  static Future<bool> isLoggedIn() async {
    prefs = await SharedPreferences.getInstance();
    bool? loggedIn = prefs.getBool("log_in");
    return loggedIn ?? false;
  }

  static void setUserData(User user) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", user.id);
    await prefs.setString("name", user.name);
    await prefs.setString("email", user.email);
    await prefs.setString("password", user.password);
    await prefs.setString("image", user.image);
  }

  static void deleteUserData() async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", "");
    await prefs.setString("name", "");
    await prefs.setString("email", "");
    await prefs.setString("password", "");
    await prefs.setString("image", "");
  }

  static void updateUserName(String name) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString("name", name);
  }

  static void updateUserId(String id) async{
    prefs = await SharedPreferences.getInstance();
    await prefs.setString("id", id);
  }

  static void updatePassword(String pwd) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString("password", pwd);
  }

  static void updateEmail(String email) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString("email", email);
  }

  static Future<String> getUserId() async {
    prefs = await SharedPreferences.getInstance();
    String id = prefs.getString("id") ?? '';
    return id;
  }

  static Future<String> getUserName() async {
    prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("name") ?? '';
    return name;
  }

  static Future<String> getUserEmail() async {
    prefs = await SharedPreferences.getInstance();
    String email = prefs.getString("email") ?? '';
    return email;
  }

  static Future<String> getUserPassword() async {
    prefs = await SharedPreferences.getInstance();
    String password = prefs.getString("password") ?? '';
    return password;
  }

  static Future<String> getUserImage() async {
    prefs = await SharedPreferences.getInstance();
    String image = prefs.getString("image") ?? '';
    return image;
  }

  static void setDarkTheme(bool isDarkTheme) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setBool("dark_theme", isDarkTheme);
  }

  static Future<bool> isDarkTheme() async {
    prefs = await SharedPreferences.getInstance();
    bool? darkTheme = prefs.getBool("dark_theme");
    return darkTheme ?? false;
  }
}
