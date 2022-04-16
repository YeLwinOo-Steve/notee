import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animations/animations.dart';
import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';

import 'pages.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key, this.pageIndex = 0}) : super(key: key);
  int pageIndex;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _pageIndex;
  bool _isDarkTheme = false;
  final accountController = Get.find<AccountController>();
  @override
  initState() {
    super.initState();
    _pageIndex = widget.pageIndex;
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Allow Notifications'),
            content: const Text('Our app would like to send you notifications'),
            actions: [
              TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text(
                    "Don't Allow",
                    style: kTitleDangerTextStyle,
                  )),
              TextButton(
                  onPressed: () {
                    AwesomeNotifications()
                        .requestPermissionToSendNotifications()
                        .then((_) => Get.back());
                  },
                  child: const Text(
                    "Allow",
                    style: kTitleTextStyle,
                  )),
            ],
          ),
        );
      }
    });
    checkTheme();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkTheme();
  }

  void checkTheme() {
    accountController.isDarkTheme.then((value) {
      setState(() {
        _isDarkTheme = value;
      });
    });
  }

  Widget bottomNav(String img, int index, String label) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _pageIndex = index;
        });
      },
      child: AnimatedContainer(
          height: 50.0,
          decoration: BoxDecoration(
            color: index == _pageIndex
                ? kIconColor.withOpacity(0.8)
                : Theme.of(context).bottomNavigationBarTheme.backgroundColor,
            borderRadius: const BorderRadius.all(kCircularRadius),
          ),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInToLinear,
          child: Card(
            elevation: index == _pageIndex ? 10.0 : 0.0,
            color: Colors.transparent,
            margin: const EdgeInsets.all(0.0),
            shape: kRoundedRectangleBorder,
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  img,
                  width: 40.0,
                  height: 40.0,
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: kAnimateDurationMs),
                  opacity: _pageIndex == index ? 1.0 : 0.0,
                  child: Text(
                    _pageIndex == index ? label : '',
                    style: kNavTextStyle,
                  ),
                )
              ]),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    List pages = [
      NotePage(),
      const TodoPage(),
      const StopwatchPage(),
    ];
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'NOTEE',
          style: TextStyle(
            fontFamily: 'TripDenied',
            color: _isDarkTheme ? Colors.white : kTextColor,
            fontSize: 60.0,
            letterSpacing: 5,
            shadows: <Shadow>[
              Shadow(
                  offset: const Offset(5.0, 5.0),
                  blurRadius: 5.0,
                  // color: Colors.tealAccent.shade200,
                  color: _isDarkTheme
                      ? Colors.white.withOpacity(0.3)
                      : Colors.teal.withOpacity(0.3)),
            ],
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          OpenContainer(
            openBuilder: (context, _) => Profile(),
            transitionDuration:
                const Duration(milliseconds: kAnimateDurationMs),
            closedShape: const CircleBorder(),
            closedColor: Theme.of(context).scaffoldBackgroundColor,
            openColor: Theme.of(context).scaffoldBackgroundColor,
            onClosed: (never) {
              checkTheme();
            },
            closedElevation: 0.0,
            closedBuilder: (context, openContainer) => IconButton(
              padding: const EdgeInsets.all(15.0),
              iconSize: 30.0,
              color: kIconColor,
              icon: const Icon(Icons.account_circle),
              onPressed: openContainer,
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: pages[_pageIndex],
      bottomNavigationBar: Card(
        elevation: 10.0,
        shadowColor: Colors.blueGrey.shade200,
        shape: kRoundedRectangleBorder,
        margin: const EdgeInsets.only(bottom: 5.0, left: 10.0, right: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: _isDarkTheme
                ? Colors.teal.shade200
                : Colors.teal.shade300.withOpacity(0.5),
            borderRadius: const BorderRadius.all(kCircularRadius),
          ),
          child: Row(children: <Widget>[
            Expanded(child: bottomNav(kStickyNoteImg, 0, 'Note')),
            Expanded(child: bottomNav(kTodoListImg, 1, 'To Do')),
            Expanded(child: bottomNav(kTimerImg, 2, 'Timer'))
          ]),
        ),
      ),
    );
  }
}
