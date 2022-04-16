import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/views/pages/pages.dart';
import 'package:note_taker/views/widgets/widgets.dart';

class Reports extends StatefulWidget {
  Reports({Key? key}) : super(key: key);
  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> with TickerProviderStateMixin {
  static int _selectedReportIndex = 0;
  int touchIndex = -1;
  final noteController = Get.find<NoteController>();
  final catController = Get.find<CategoryController>();
  final todoController = Get.find<TodoController>();

  int completedTasksLength = 0;
  int pendingTasksLength = 0;
  int year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    todoController.setCompleteAndPendingTasks();
    setTasksLength();
  }

  setTasksLength() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          completedTasksLength = todoController.completedTasksLength;
          pendingTasksLength = todoController.todayPendingTasksLength;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Notes & Todo Reports',
          style: TextStyle(color: kTextColor),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios_rounded, color: kIconColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        actions: [],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reportTabs(),
          _selectedReportIndex == 0 ? _notesPieChart() : _getTodoReport(),
        ],
      ),
    );
  }

  _reportTabs() {
    return Container(
      height: 80,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
              child: CustomElevatedButton(
            shape: kMediumRoundedRectangleBorder.copyWith(
                borderRadius: const BorderRadius.only(
                    topLeft: kCircularSmallRadius,
                    bottomLeft: kCircularSmallRadius)),
            height: 40.0,
            letterSpacing: 0.5,
            fontSize: 16,
            borderRadius: const BorderRadius.only(
                topLeft: kCircularSmallRadius,
                bottomLeft: kCircularSmallRadius),
            elevation: _selectedReportIndex == 0 ? 15.0 : 0.0,
            label: 'Notes Report',
            bgColor: _selectedReportIndex == 0
                ? kIconColor
                : kIconColor.withOpacity(0.4),
            onPressed: () {
              setState(() {
                _selectedReportIndex = 0;
              });
            },
          )),
          const SizedBox(width: 1.0),
          Expanded(
              child: CustomElevatedButton(
            shape: kMediumRoundedRectangleBorder.copyWith(
                borderRadius: const BorderRadius.only(
                    topRight: kCircularSmallRadius,
                    bottomRight: kCircularSmallRadius)),
            height: 40.0,
            letterSpacing: 0.5,
            fontSize: 16,
            borderRadius: const BorderRadius.only(
                topRight: kCircularSmallRadius,
                bottomRight: kCircularSmallRadius),
            elevation: _selectedReportIndex == 1 ? 15.0 : 0.0,
            label: 'Todo Report',
            bgColor: _selectedReportIndex == 1
                ? kIconColor
                : kIconColor.withOpacity(0.4),
            onPressed: () {
              setState(() {
                _selectedReportIndex = 1;
                completedTasksLength = 0;
                pendingTasksLength = 0;
                setTasksLength();
              });
            },
          )),
        ],
      ),
    );
  }

  _notesPieChart() {
    return Expanded(
      child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(height: 15.0),
            noteController.noteListLength == 0
                ? const EmptyNoteReport()
                : CustomPieChart(),
            const SizedBox(height: 50.0),
            ListView(
              shrinkWrap: true,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                      left: 25.0, right: 25.0, top: 10.0, bottom: 10.0),
                  child: Text(
                    'Categories',
                    style: kTitleTextStyle,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25.0, top: 10.0, bottom: 20.0),
                  child: _getPieChartIndicators(),
                ),
              ],
            )
          ]),
    );
  }

  _getPieChartIndicators() {
    return const CustomPieIndicators();
  }

  _getTodoReport() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 0.0),
        child: ListView(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Tasks Overview',
              style: kTitleTextStyle,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                        height: 170,
                        margin: const EdgeInsets.only(right: 2.0),
                        decoration: const BoxDecoration(
                            color: kIconColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(
                                    milliseconds: kAnimateDurationMs),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: Center(child: child),
                                  );
                                },
                                child: Text(
                                  '$completedTasksLength',
                                  key:
                                      ValueKey<String>('$completedTasksLength'),
                                  style: kLargeTitleTextStyle,
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Text(
                                'Tasks Completed',
                                style: kBodyWhiteTextStyle.copyWith(
                                    fontWeight: FontWeight.w500),
                              )
                            ],
                          ),
                        ))),
                Expanded(
                    child: Container(
                        height: 170,
                        margin: const EdgeInsets.only(left: 2.0),
                        decoration: const BoxDecoration(
                            color: kIconColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        child: Column(
                          children: [
                            const Align(
                              alignment: Alignment.topRight,
                              child: Tooltip(
                                message: 'All undone tasks for Today',
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                                triggerMode: TooltipTriggerMode.tap,
                                waitDuration: Duration(milliseconds: 400),
                                showDuration: Duration(milliseconds: 600),
                                decoration: BoxDecoration(
                                    color: Colors.blueGrey,
                                    borderRadius: BorderRadius.all(
                                        kCircularMediumRadius)),
                                child: IconButton(
                                  padding: EdgeInsets.all(0.0),
                                  icon: Icon(
                                    Icons.info,
                                    color: Colors.white,
                                  ),
                                  onPressed: null,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(
                                      milliseconds: kAnimateDurationMs),
                                  transitionBuilder: (Widget child,
                                      Animation<double> animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: Center(child: child),
                                    );
                                  },
                                  child: Text(
                                    '$pendingTasksLength',
                                    key:
                                        ValueKey<String>('$pendingTasksLength'),
                                    style: kLargeTitleTextStyle,
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Text(
                                  'Tasks Pending',
                                  style: kBodyWhiteTextStyle.copyWith(
                                      fontWeight: FontWeight.w500),
                                )
                              ],
                            )
                          ],
                        ))),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
            const Text('Monthly Task Completion', style: kTitleTextStyle),
            const SizedBox(height: 20.0),
            _buildTodoLineChart(),
            const SizedBox(
              height: 10.0,
            ),
            Column(
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      height: 30.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                          color: const Color(0xff4af699),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          border: Border.all(color: Colors.grey)),
                    ),
                    Text(
                      'Completed Tasks',
                      style:
                          kBodyTextStyle.copyWith(fontWeight: FontWeight.w800),
                    )
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  children: [
                    const SizedBox(
                      width: 40,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      height: 30.0,
                      width: 50.0,
                      decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(5.0))),
                    ),
                    Text(
                      'Pending Tasks',
                      style:
                          kBodyTextStyle.copyWith(fontWeight: FontWeight.w800),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30.0),
            const Text(
              'Tasks in next 7 Days',
              style: kTitleTextStyle,
            ),
            const SizedBox(
              height: 20,
            ),
            const CustomBarChart(),
            const SizedBox(height: 30.0),
          ],
        ),
      ),
    );
  }

  _buildTodoLineChart() {
    return AspectRatio(
      aspectRatio: 0.95,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [Color(0xff009787), Colors.teal],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(5.0),
                      iconSize: 30.0,
                      icon: const Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          year--;
                        });
                      },
                    ),
                    AnimatedSwitcher(
                      duration:
                          const Duration(milliseconds: kAnimateDurationMs),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return SlideTransition(
                          child: child,
                          position: Tween<Offset>(
                                  begin: const Offset(0.0, -1.0),
                                  end: const Offset(0.0, 0.0))
                              .animate(animation),
                        );
                      },
                      child: Text(
                        '$year',
                        key: ValueKey<String>('$year'),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    year < DateTime.now().year
                        ? IconButton(
                            padding: const EdgeInsets.all(5.0),
                            iconSize: 30.0,
                            icon: const Icon(
                              Icons.keyboard_arrow_right_rounded,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                if (year < DateTime.now().year) {
                                  year++;
                                }
                              });
                            },
                          )
                        : const SizedBox(
                            width: 50.0,
                          ),
                  ],
                ),
                const Text(
                  'Monthly Task Completion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 30,
                ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(right: 30.0, left: 5.0, bottom: 20.0),
                    child: CustomLineChart(
                      year: year,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
