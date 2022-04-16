import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:animations/animations.dart';
import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/views/pages/pages.dart';
import 'package:note_taker/views/widgets/widgets.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({Key? key}) : super(key: key);

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  final _accountController = Get.find<AccountController>();
  final ScrollController _scrollController = ScrollController();
  final todoController = Get.find<TodoController>();
  String _date = Utils.formatDate(DateTime.now());
  final DateTime _today = DateTime.now();
  double topCalendar = 0;
  bool _isFuture = false;
  bool _isDarkTheme = false;
  bool _closeCalendar = true;
  late List<Todo> _todoList;
  double _offset = 0.0;

  bool _isScrollEnd = false;
  @override
  void initState() {
    super.initState();
    setTodoListByDate();
    _accountController.isDarkTheme.then((value){
      setState(() {
        _isDarkTheme = value;
      });
    });

    _scrollController.addListener(() {
      double value = _scrollController.offset / 110;
      setState(() {
        if (_todoList.length > 6) {
          _isScrollEnd = _scrollController.offset >=
              _scrollController.position.maxScrollExtent - 30;
        }
        topCalendar = value;
        if (_scrollController.offset != 0.0) {
          _offset = _scrollController.offset;
        }
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    AwesomeNotifications().actionSink.close();
    super.dispose();
  }

  setTodoListByDate() {
    _todoList = [];
    setState(() {
      _todoList = todoController.getTodoByDueDate(_date);
    });
  }

  buildCalendar() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: kAnimateDurationMs),
      opacity: _closeCalendar ? 0 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: kAnimateDurationMs),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        height: _closeCalendar ? 0 : 346,
        margin: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: kIconColor,
        ),
        child: Card(
          elevation: 10.0,
          color: _isDarkTheme
              ? Colors.white30
              : Colors.white.withOpacity(0.8),
          margin: const EdgeInsets.all(0.0),
          shadowColor: kIconColor.withOpacity(0.2),
          shape: kRoundedRectangleBorder.copyWith(
              borderRadius: const BorderRadius.all(kCircularMediumRadius)),
          child: SingleChildScrollView(
            child: StatefulBuilder(
              builder: (BuildContext context, void Function(void Function()) setState) {
                return Theme(
                  data: ThemeData().copyWith(
                    colorScheme: const ColorScheme.light().copyWith(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: _isDarkTheme ? Colors.white : kTextColor
                    ),
                  ),
                  child: CalendarDatePicker(
                      initialDate: DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
                      onDateChanged: (newDate) {
                        setState(() {
                          _isFuture = newDate.isAfter(_today);
                          _date = Utils.formatDate(newDate);
                          setTodoListByDate();
                          _closeCalendar = true;
                        });
                      }),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  buildTaskStatus() {
    return SizedBox(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Tasks',
                style: kTitleTextStyle.copyWith(letterSpacing: 1.2),
              ),
              Chip(
                label: Text(
                  "${_todoList.length}",
                ),
                labelStyle: const TextStyle(
                    fontSize: 18,
                    color: kTextColor,
                    fontWeight: FontWeight.w800),
                backgroundColor: Colors.teal.shade100,
              ),
            ],
          ),
          SizedBox(
            height: 40.0,
            child: ElevatedButton(
                style: ButtonStyle(
                    elevation: MaterialStateProperty.all(10.0),
                    shadowColor:
                        MaterialStateProperty.all(kIconColor.withOpacity(0.8)),
                    backgroundColor: MaterialStateProperty.all(kIconColor),
                    foregroundColor: MaterialStateProperty.all(
                      Colors.teal.shade100,
                    ),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ))),
                onPressed: () {
                  setState(() {
                    _closeCalendar = !_closeCalendar;
                    if (_todoList.isNotEmpty) {
                      _scrollController.animateTo(0.0,
                          duration:
                              const Duration(milliseconds: kAnimateDurationMs),
                          curve: Curves.easeInOut);
                    }
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _date,
                      style: const TextStyle(fontSize: 13.0),
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Icon(
                      Icons.date_range,
                      size: 20,
                      color: Colors.teal.shade100,
                    )
                  ],
                )),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      floatingActionButton: Visibility(
        visible: !_isScrollEnd,
        child: Card(
          margin: const EdgeInsets.all(0.0),
          elevation: 20.0,
          shadowColor: kIconColor,
          shape: kRoundedRectangleBorder,
          color: kIconColor,
          child: OpenContainer(
            transitionType: ContainerTransitionType.fadeThrough,
            transitionDuration:
                const Duration(milliseconds: kAnimateDurationMs),
            openBuilder: (context, _) => TodoManagerPage(),
            closedShape: const CircleBorder(),
            openColor: kPrimaryColor,
            middleColor: kPrimaryColor,
            closedColor: kIconColor,
            closedElevation: 0.0,
            closedBuilder: (context, openContainer) => FloatingActionButton(
                mini: true,
                onPressed: openContainer,
                backgroundColor: Colors.transparent,
                elevation: 20.0,
                child: Image.asset(kAddTodoImg, width: 30.0, height: 30.0)),
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTaskStatus(),
            buildCalendar(),
            const SizedBox(height: 10.0),
            Expanded(
              child: (_todoList.isEmpty)
                  ? EmptyTodoPage()
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _todoList.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        double scale = 1.0;
                        if (topCalendar > 0.2) {
                          scale = index + 0.8 - topCalendar;
                          if (scale <= 0.0) {
                            scale = 0;
                          } else if (scale >= 1.0) {
                            scale = 1.0;
                          }
                        }
                        return Opacity(
                          opacity: scale,
                          child: Transform(
                            transform: Matrix4.identity()..scale(scale, scale),
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(bottom: 10.0, top: 5.0),
                              child: SizedBox(
                                height: 95.0,
                                child: Dismissible(
                                    key: Key(_todoList[index].id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding:
                                          const EdgeInsets.only(right: 20.0),
                                      decoration: const BoxDecoration(
                                        color: kRedColor,
                                        borderRadius: kLeftRoundedBorderRadius,
                                      ),
                                      child: Image.asset(
                                        kTrashImg,
                                        width: 30.0,
                                        height: 30.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (direction) {
                                      setState(() {
                                        todoController.removeTodo(_todoList[index].id);
                                        _todoList.removeWhere((todo) => todo.id == _todoList[index].id);
                                        _scrollController.animateTo(0.0,
                                            duration: const Duration(
                                                milliseconds: 500),
                                            curve: Curves.elasticInOut);
                                      });
                                      CustomSnackbar.buildSnackBar(
                                        context: context,
                                        content: 'Task Deleted',
                                        contentColor: kTextColor,
                                        duration: kAnimateDurationMs + 400,
                                        bgColor: Colors.teal.shade100,
                                      );
                                    },
                                    child: TodoItem(
                                      index: index,
                                      todo: _todoList[index],
                                      isFuture: _isFuture,
                                    )),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
