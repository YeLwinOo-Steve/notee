import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/utils/validators.dart';
import 'package:note_taker/views/pages/pages.dart';
import 'package:note_taker/views/widgets/widgets.dart';

class TodoManagerPage extends StatefulWidget {
  TodoManagerPage({Key? key, this.todo}) : super(key: key);
  Todo? todo;
  @override
  _TodoManagerPageState createState() => _TodoManagerPageState();
}

class _TodoManagerPageState extends State<TodoManagerPage> {
  final todoController = Get.find<TodoController>();
  bool isEdit = false;
  String title = 'Add Task';
  late String _id;
  late String _refId;
  late Todo todo;
  DateTime _selectedDueDate = DateTime.now();
  late String _dueDate;
  late String _dueTime;
  bool _isDarkTheme = false;
  int _selectedRepeatIndex = 0;
  late String _selectedRepeatType;
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<TextEditingController> _subtaskControllerList = [];
  List<bool> _subtaskDone = [];
  List<String> _subtaskName = [];
  List<String> _removedSubtaskId = [];
  final List<Subtask> _subtasks = [];
  @override
  void initState() {
    super.initState();
    _id = Utils.generateTodoId();
    if (widget.todo != null) {
      setState(() {
        isEdit = true;
      });
    }
    checkMode();
    _isDarkTheme = Utils.checkTheme();
  }

  @override
  void dispose() {
    _taskController.dispose();
    _noteController.dispose();
    for (TextEditingController controller in _subtaskControllerList) {
      controller.dispose();
    }
    super.dispose();
  }

  ///Check if it's Edit Mode
  checkMode() {
    if (isEdit) {
      title = 'Edit Task';
      setTodoData();
    } else {
      _selectedRepeatType =
          Utils.getRepeatTypes(REPEAT_TYPES.values[_selectedRepeatIndex]);
      _dueDate = Utils.formatDate(_selectedDueDate);
      _dueTime = Utils.formatTime(DateTime.now());
    }
  }

  setTodoData() {
    todo = widget.todo!;
    _id = todo.id;
    _refId = todo.refId;
    _taskController.text = todo.task;
    _subtasks.addAll(todoController.getSubtasksByTodoId(todo));
    _subtaskName = todoController
        .getSubtasksByTodoId(todo)
        .map((subtask) => subtask.name)
        .toList();
    _subtaskDone = todoController
        .getSubtasksByTodoId(todo)
        .map((subtask) => subtask.done)
        .toList();
    setSubtaskControllers();
    _dueDate = todo.dueDate;
    _dueTime = todo.reminderTime;
    _selectedRepeatType = todo.repeatType;
    _selectedRepeatIndex = Utils.getRepeatTypesIndex(_selectedRepeatType);
    _noteController.text = todo.note;
  }

  setSubtaskControllers() {
    for (int i = 0; i < _subtasks.length; i++) {
      _subtaskControllerList.add(TextEditingController());
      _subtaskControllerList[i].text = _subtasks[i].name;
    }
  }

  onSave() {
    String task = _taskController.text;
    String note = _noteController.text;
    if (Validators.validateTask(task)) {
      if (isEdit) {
        updateSubtaskList();
        buildEditTask(task, note);
      } else {
        buildSubtaskList();
        buildNewTask(task, note);
      }
      CustomSnackbar.buildSnackBar(
        context: context,
        content: 'Task ${isEdit ? 'edited' : 'added'} successfully!',
        contentColor: Colors.teal,
        bgColor: Colors.teal.shade100,
      );
      Future.delayed(const Duration(milliseconds: kAnimateDurationMs - 100),
          () {
        Get.off(
            () => HomePage(
                  pageIndex: 1,
                ),
            preventDuplicates: false);
      });
    } else {
      CustomSnackbar.buildSnackBar(
        context: context,
        content: 'Please fill task name!',
        contentColor: Colors.red,
        bgColor: Colors.red.shade100,
      );
    }
  }

  void onDelete() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              actions: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: Image.asset(
                    kCancelImg,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    todoController.removeTodo(_id);
                    deleteSubtasks();
                    Future.delayed(const Duration(milliseconds: 300), () {
                      CustomSnackbar.buildSnackBar(
                        context: context,
                        content: 'Task deleted successfully!',
                        contentColor: Colors.teal,
                        bgColor: Colors.teal.shade100,
                      );
                    });
                    Future.delayed(
                        const Duration(milliseconds: kAnimateDurationMs - 100),
                        () {
                      Get.offUntil(
                          GetPageRoute(
                              page: () => HomePage(
                                    pageIndex: 1,
                                  ),

                              ///TODO: transition here
                              transition: Transition.circularReveal),
                          (route) => false);
                    });
                  },
                  icon: Image.asset(
                    kDoneImg,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              title: const Align(
                alignment: Alignment.center,
                child: Text(
                  "Delete Task",
                  style: kTitleTextStyle,
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Delete this task?',
                    style: kBodyTextStyle.copyWith(
                        color: kRedColor, letterSpacing: 1.3, fontSize: 17),
                  ),
                ],
              ),
            );
          });
        });
  }

  buildNewTask(String task, String note) {
    Todo todo = Todo(
        id: _id,
        task: task,
        dueDate: _dueDate,
        reminderTime: _dueTime,
        repeatType: _selectedRepeatType,
        dateTimeCreated: Utils.formatDate(DateTime.now()),
        note: note);
    todoController.addTodo(todo);
  }

  buildEditTask(String task, String note) {
    Todo todo = Todo(
        id: _id,
        task: task,
        refId: _refId,
        dueDate: _dueDate,
        reminderTime: _dueTime,
        repeatType: _selectedRepeatType,
        note: note);
    todoController.updateTodo(todo);
  }

  void deleteSubtasks() {
    _subtasks.clear();
    _subtasks.addAll(todoController.getSubtasksByTodoId(todo));
    for (int i = 0; i < _subtasks.length; i++) {
      todoController.deleteSubtask(_subtasks[i].id);
    }
  }

  updateSubtaskList() {
    int index = 0;
    for (index = 0; index < _subtasks.length; index++) {
      if (_subtasks[index].name != _subtaskName[index]) {
        todoController.updateSubtaskName(
            _subtasks[index].id, _subtaskName[index]);
      }
      if (_subtasks[index].done != _subtaskDone[index]) {
        todoController.updateSubtaskDone(
            _subtasks[index].id, _subtaskDone[index]);
      }
    }
    if (index != _subtaskName.length) {
      while (index < _subtaskName.length) {
        Subtask _subtask = Subtask(
            id: Utils.generateSubtaskId(),
            name: _subtaskName[index],
            done: _subtaskDone[index],
            todoId: _id);
        todoController.addSubtask(_subtask);
        index++;
      }
    }

    for (int i = 0; i < _removedSubtaskId.length; i++) {
      todoController.deleteSubtask(_removedSubtaskId[i]);
    }
  }

  buildSubtaskList() {
    for (int i = 0; i < _subtaskName.length; i++) {
      Subtask _subtask = Subtask(
          id: Utils.generateSubtaskId(),
          name: _subtaskName[i],
          done: _subtaskDone[i],
          todoId: _id);
      todoController.addSubtask(_subtask);
    }
  }

  TextField taskInput() {
    return TextField(
      cursorColor: _isDarkTheme ? kPrimaryColor : kIconColor,
      cursorWidth: 4.0,
      cursorRadius: const Radius.circular(20.0),
      style: _isDarkTheme
          ? kTitleTextStyle.copyWith(
              color: kPrimaryColor, fontWeight: FontWeight.normal)
          : kTitleTextStyle.copyWith(fontWeight: FontWeight.normal),
      controller: _taskController,
      minLines: 1,
      maxLines: null,
      decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Enter the task',
          hintStyle: TextStyle(
              fontWeight: FontWeight.normal,
              color: _isDarkTheme
                  ? kPrimaryColor.withOpacity(0.4)
                  : kTextColor.withOpacity(0.4))),
    );
  }

  Divider buildDivider() {
    return Divider(
      height: 3,
      thickness: 0.5,
      color: kIconColor.withOpacity(0.3),
    );
  }

  SizedBox subtaskListTile(int index) {
    return SizedBox(
      key: UniqueKey(),
      height: 40.0,
      child: ListTile(
        leading: CustomCheckbox(
          isChecked: _subtaskDone[index],
          setCheck: (value) {
            setState(() {
              _subtaskDone[index] = value;
            });
          },
          scale: 1,
        ),
        horizontalTitleGap: 0.0,
        title: TextField(
          onChanged: (String str) {
            _subtaskName[index] = str.trim();
          },
          autofocus: false,
          decoration: InputDecoration(
            hintText: 'Enter Subtask',
            hintStyle: TextStyle(
                fontWeight: FontWeight.normal,
                color: _isDarkTheme
                    ? kPrimaryColor.withOpacity(0.4)
                    : kTextColor.withOpacity(0.4)),
            border: InputBorder.none,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
          ),
          style: kSmallTextStyle.copyWith(
              fontSize: 14.0,
              color: _isDarkTheme ? kPrimaryColor : kTextColor,
              decoration: _subtaskDone[index]
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationThickness: 2),
          controller: _subtaskControllerList[index],
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.clear,
            size: 20,
            color: kGreyColor,
          ),
          onPressed: () {
            setState(() {
              if (isEdit) {
                _removedSubtaskId.add(_subtasks[index].id);
                _subtasks.removeAt(index);
              }
              _subtaskName.removeAt(index);
              _subtaskControllerList.removeAt(index);
              _subtaskDone.removeAt(index);
            });
          },
        ),
      ),
    );
  }

  ConstrainedBox subtasks() {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(minHeight: 150, maxWidth: double.infinity),
      child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _subtaskName.length,
          itemBuilder: (context, index) {
            return subtaskListTile(index);
          }),
    );
  }

  ListTile subtask() {
    return ListTile(
      onTap: () {
        setState(() {
          _subtaskControllerList.add(TextEditingController());
          _subtaskDone.add(false);
          _subtaskName.add('');
        });
      },
      horizontalTitleGap: 0.0,
      leading: const Icon(
        Icons.add,
        color: kIconColor,
      ),
      title: const Text(
        'Add Subtask',
        style: TextStyle(color: kTextColor, fontWeight: FontWeight.w600),
      ),
    );
  }

  ListTile dueDate() {
    return ListTile(
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: _selectedDueDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 100)),
            builder: (context, child) {
              return StatefulBuilder(builder: (context, setState) {
                return Theme(
                  data: ThemeData().copyWith(
                    colorScheme: const ColorScheme.light().copyWith(
                      primary: Colors.teal,
                    ),
                  ),
                  child: child!,
                );
              });
            });
        if (pickedDate != null && pickedDate != _selectedDueDate) {
          setState(() {
            _selectedDueDate = pickedDate;
            _dueDate = Utils.formatDate(_selectedDueDate);
          });
        }
      },
      horizontalTitleGap: 0.0,
      leading: Image.asset(
        kCalenderImg,
        fit: BoxFit.scaleDown,
        width: 22.0,
        height: 22.0,
      ),
      title: const Text(
        'Due Date',
        style: TextStyle(color: kTextColor),
      ),
      trailing: TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(kIconColor.withOpacity(0.3))),
        onPressed: null,
        child: Text(
          _dueDate,
          style: TextStyle(color: _isDarkTheme ? kPrimaryColor : kTextColor),
        ),
      ),
    );
  }

  ListTile timeReminder() {
    return ListTile(
      onTap: () {
        showCupertinoModalPopup(
            context: context,
            builder: (BuildContext builder) {
              return Container(
                height: MediaQuery.of(context).copyWith().size.height * 0.25,
                decoration: BoxDecoration(
                    color: _isDarkTheme ? Colors.white60 : kPrimaryColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: kCircularMediumRadius,
                        topRight: kCircularMediumRadius)),
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  onDateTimeChanged: (value) {
                    setState(() {
                      _dueTime = Utils.formatTime(value);
                    });
                  },
                  initialDateTime: Utils.getTime(_dueTime),
                ),
              );
            });
      },
      horizontalTitleGap: 0.0,
      leading: Image.asset(
        kReminderImg,
        fit: BoxFit.scaleDown,
        width: 22.0,
        height: 22.0,
      ),
      title: const Text(
        'Time & Reminder',
        style: TextStyle(color: kTextColor),
      ),
      trailing: TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(kIconColor.withOpacity(0.3))),
        onPressed: null,
        child: Text(
          _dueTime,
          style: TextStyle(color: _isDarkTheme ? kPrimaryColor : kTextColor),
        ),
      ),
    );
  }

  changeRepeatType() {
    setState(() {
      _selectedRepeatType =
          Utils.getRepeatTypes(REPEAT_TYPES.values[_selectedRepeatIndex]);
      Get.back();
    });
  }

  ListTile repeatTask() {
    return ListTile(
      onTap: () async {
        await showDialog(
            context: context,
            builder: (context) {
              return StatefulBuilder(builder: (context, setState) {
                return AlertDialog(
                  actions: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: Image.asset(
                        kCancelImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      onPressed: () => changeRepeatType(),
                      icon: Image.asset(
                        kDoneImg,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  title: const Text(
                    "Repeat Task",
                    style: kTitleTextStyle,
                  ),
                  content: SizedBox(
                    width: 200.0,
                    height: 150.0,
                    child: Wrap(
                      alignment: WrapAlignment.spaceEvenly,
                      children: List.generate(
                          REPEAT_TYPES.values.length,
                          (index) => ChoiceChip(
                              padding: const EdgeInsets.all(10.0),
                              labelStyle: _selectedRepeatIndex == index
                                  ? kBodyTextStyle.copyWith(color: Colors.white)
                                  : kBodyTextStyle,
                              label: Text(
                                Utils.getRepeatTypes(
                                    REPEAT_TYPES.values[index]),
                              ),
                              selected:
                                  _selectedRepeatIndex == index ? true : false,
                              onSelected: (bool isSelected) {
                                if (isSelected) {
                                  setState(() {
                                    _selectedRepeatIndex = index;
                                  });
                                }
                              },
                              backgroundColor: kIconColor.withOpacity(0.3),
                              selectedColor: kIconColor)),
                    ),
                  ),
                );
              });
            });
      },
      horizontalTitleGap: 0.0,
      leading: const Icon(
        Icons.repeat_rounded,
        color: kIconColor,
        size: 27,
      ),
      title: const Text(
        'Repeat Task',
        style: TextStyle(color: kTextColor),
      ),
      trailing: TextButton(
        style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all(kIconColor.withOpacity(0.3))),
        onPressed: null,
        child: Text(
          _selectedRepeatType,
          style: TextStyle(color: _isDarkTheme ? kPrimaryColor : kTextColor),
        ),
      ),
    );
  }

  ListTile note() {
    return ListTile(
      horizontalTitleGap: 0.0,
      isThreeLine: true,
      leading: Image.asset(
        kNoteImg,
        fit: BoxFit.scaleDown,
        width: 25.0,
        height: 25.0,
      ),
      title: const Text(
        'Add Note',
        style: TextStyle(color: kTextColor),
      ),
      minVerticalPadding: 10.0,
      subtitle: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: TextField(
          controller: _noteController,
          cursorColor: _isDarkTheme ? kPrimaryColor : kIconColor,
          style: _isDarkTheme
              ? kBodyTextStyle.copyWith(
                  color: kPrimaryColor, fontWeight: FontWeight.normal)
              : kBodyTextStyle.copyWith(fontWeight: FontWeight.normal),
          decoration: const InputDecoration(
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(kCircularMediumRadius),
                borderSide: BorderSide(width: 0.5, color: kIconColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(kCircularMediumRadius),
                borderSide: BorderSide(width: 0.5, color: kIconColor)),
          ),
          minLines: 3,
          maxLines: null,
        ),
      ),
    );
  }

  List<Widget> appBarActions() {
    return [
      Visibility(
        visible: isEdit,
        child: IconButton(
          onPressed: onDelete,
          icon: Image.asset(
            kDeleteImg,
            fit: BoxFit.cover,
          ),
        ),
      ),
      IconButton(
        onPressed: onSave,
        icon: Image.asset(
          kDoneImg,
          fit: BoxFit.cover,
        ),
      ),
      const SizedBox(width: 10.0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(color: kTextColor),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.clear, color: kIconColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
        actions: appBarActions(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: taskInput()),
              _subtaskName.isEmpty
                  ? Container(
                      height: 150.0,
                    )
                  : subtasks(),
              const SizedBox(height: 10.0),
              subtask(),
              buildDivider(),
              dueDate(),
              buildDivider(),
              timeReminder(),
              buildDivider(),
              repeatTask(),
              buildDivider(),
              note(),
            ],
          ),
        ),
      ),
    );
  }
}
