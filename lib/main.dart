import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'views/theme_data.dart';
import 'views/pages/pages.dart';
import 'components/components.dart';
import 'controllers/controllers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotifications();
  await Firebase.initializeApp();
  initializeControllers();
  runApp(NoteApp());
}

void initializeNotifications() {
  AwesomeNotifications().initialize(
    'resource://drawable/res_notification_app_icon',
    [
      NotificationChannel(
        channelKey: 'scheduled_channel',
        channelName: 'Scheduled Notifications',
        defaultColor: Colors.teal,
        locked: false,
        playSound: true,
        importance: NotificationImportance.High,
        soundSource: 'resource://raw/res_custom_notification',
        channelDescription: '',
      ),
    ],
  );
}

void initializeControllers() {
  Get.put<NoteController>(NoteController());
  Get.put<CategoryController>(CategoryController());
  Get.put<TodoController>(TodoController());
  Get.put<AccountController>(AccountController());
}

class NoteApp extends StatefulWidget {
  NoteApp({Key? key}) : super(key: key);

  @override
  State<NoteApp> createState() => _NoteAppState();
}

class _NoteAppState extends State<NoteApp> {
  final accountController = Get.find<AccountController>();

  bool _isDarkTheme = false;

  void checkTheme() {
    accountController.isDarkTheme.then((value) {
      setState(() {
        _isDarkTheme = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    checkTheme();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Notee',
      getPages: AppRoutes().pages,
      theme: kLightTheme,
      darkTheme: kDarkTheme,
      themeMode: _isDarkTheme ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(),
    );
  }
}
