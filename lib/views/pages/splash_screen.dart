import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';

class SplashScreen extends StatefulWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool _isDarkTheme = false;
  final accountController = Get.find<AccountController>();
  bool _visible = true;
  late AnimationController animationController;

  late Animation<double> animation;

  startTime() async {
    var _duration = const Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Get.offNamed('/home');
  }

  @override
  void initState() {
    super.initState();
    accountController.isDarkTheme.then((value) {
      setState(() {
        _isDarkTheme = value;
      });
    });

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: kAnimateDurationMs),
    );
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    animation.addListener(() {
      setState(() {
        _visible = !_visible;
      });
    });
    animationController.forward();

    startTime();
  }

  @override
  dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 150.0),
            child: Text(
              'NOTEE',
              style: TextStyle(
                color: _isDarkTheme ? Colors.white : kTextColor,
                fontSize: 80,
                fontFamily: 'Surfschool',
                shadows: <Shadow>[
                  Shadow(
                    offset: const Offset(4.0, 6.0),
                    blurRadius: 5.0,
                    color: _isDarkTheme
                        ? Colors.white24
                        : Colors.tealAccent.shade200,
                  ),
                  Shadow(
                    offset: const Offset(8.0, 8.0),
                    blurRadius: 6.0,
                    color: _isDarkTheme
                        ? Colors.white24
                        : Colors.tealAccent.shade200,
                  ),
                ],
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.0),
              child: SizedBox(
                height: 60,
                width: 60,
                child: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  backgroundImage: const AssetImage(
                    kHourglassImg,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
