import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/database/subtask_db_helper.dart';
import 'package:note_taker/database/todo_db_helper.dart';

class TodoController extends GetxController {
  late SubtaskDbHelper _subtaskDbHelper;
  late TodoDbHelper _todoDbHelper;
  DateFormat dateFormat = DateFormat('dd MMMM yyyy');
  List<Todo> todos = <Todo>[].obs;
  List<Subtask> subtasks = <Subtask>[].obs;
  var completedTodos = [].obs;
  var yearlyData = [].obs;
  var pendingTodos = [].obs;
  late Todo repeatedTodo;
  List<String> months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  ];

  @override
  void onInit() {
    getAllTodos();
    getAllSubtasks();
    super.onInit();
  }

  get todosLength => todos.length;
  get completedTasksLength => completedTodos.length;
  get todayPendingTasksLength {
    String today = Utils.formatDate(DateTime.now());
    List todayUndoneTasks =
        pendingTodos.where((task) => task.dueDate == today).toList();
    return todayUndoneTasks.length;
  }

  addTodo(Todo todo) {
    _todoDbHelper = TodoDbHelper.instance;
    List<Todo> todoList = [];
    todoList.add(todo);
    _todoDbHelper.insertTodo(todo);

    DateTime fromDate = dateFormat.parseStrict(todo.dueDate);
    DateTime toDate = fromDate.add(const Duration(days: 50));
    int dayDifference = Utils.daysBetween(fromDate, toDate);
    int day = int.parse(todo.dueDate.split(' ')[0]);
    DateTime date = fromDate;


    ///Subtasks
    // List<Subtask> subtasks= getSubtasksByTodoId(todo);

    ///Logic for Repeating Tasks,   ***Bad for Performance but I can't think of any better methods, Sorry! :( ***
    for (int i = 0; i < dayDifference; i++) {
      date = date.add(const Duration(days: 1));
      bool isWeekday = Utils.checkWeekday(date);
      String formattedDate = Utils.formatDate(date);
      int _day = int.parse(formattedDate.split(' ')[0]);

      repeatedTodo = todo.copyWith(
          id: Utils.generateTodoId(), dueDate: formattedDate, refId: todo.id);
      switch (todo.repeatType) {
        case "Daily":
          todoList.add(repeatedTodo);
          _todoDbHelper.insertTodo(repeatedTodo);
          break;
        case "Weekdays":
          if (isWeekday) {
            todoList.add(repeatedTodo);
            _todoDbHelper.insertTodo(repeatedTodo);
          }
          break;
        case "Weekends":
          if (!isWeekday) {
            todoList.add(repeatedTodo);
            _todoDbHelper.insertTodo(repeatedTodo);
          }
          break;
        case "Monthly":
          if (day == _day) {
            todoList.add(repeatedTodo);
            _todoDbHelper.insertTodo(repeatedTodo);
          }
          break;
      }
    }
    todos.addAll(todoList);
  }

  Future<void> getAllTodos() async {
    _todoDbHelper = TodoDbHelper.instance;
    await _todoDbHelper.getAllTodos().then((value) {
      todos = value;
    });
  }

  setCompleteAndPendingTasks() {
    completedTodos.clear();
    pendingTodos.clear();
    for (Todo todo in todos) {
        if (todo.done) {
          completedTodos.add(todo);
        } else {
          pendingTodos.add(todo);
        }

    }
  }

  getTodoByDueDate(String dueDate) {
    List<Todo> todoList = [];
    DateTime date = dateFormat.parseStrict(dueDate);
    for (Todo todo in todos) {
      DateTime _todoDate = dateFormat.parseStrict(todo.dueDate);
      bool isEqualDate = date.isAtSameMomentAs(_todoDate);
      if (isEqualDate) {
        todoList.add(todo);
      }
    }
    return todoList;
  }

  updateTodo(Todo todo) {
    _todoDbHelper = TodoDbHelper.instance;
    int index = todos.indexWhere((e) => e.id == todo.id);
    String oldRepeatType = todos[index].repeatType;
    String newRepeatType = todo.repeatType;
    todos[index] = todo;
    _todoDbHelper.updateTodo(todo);

    if (oldRepeatType != newRepeatType) {
      /// *** For Repeated tasks, updating Repeat Type also updates same future tasks ***
      String _id = todo.refId;
      if (todo.refId.isEmpty) _id = todo.id;
      print("REFERENCE ID: $_id\t\t${todo.refId}");
      DateTime fromDate = dateFormat.parseStrict(todo.dueDate);
      DateTime toDate = fromDate.add(const Duration(days: 50));
      int dayDifference = Utils.daysBetween(fromDate, toDate);
      int day = int.parse(todo.dueDate.split(' ')[0]);
      DateTime date = fromDate;

      ///Firstly, remove all future repeated tasks
      todos.removeWhere((task) {
        DateTime _taskDueDate = dateFormat.parseStrict(task.dueDate);
        bool isBefore = fromDate.isBefore(_taskDueDate);
        bool isSame = task.refId == _id && isBefore;
        if (isSame) {
          _todoDbHelper.deleteTodo(task.id);
        }
        return isSame;
      });

      ///Add updated tasks, same logic as adding task
      List<Todo> todoList = [];

      for (int i = 0; i < dayDifference; i++) {
        date = date.add(const Duration(days: 1));
        bool isWeekday = Utils.checkWeekday(date);
        String formattedDate = Utils.formatDate(date);
        int _day = int.parse(formattedDate.split(' ')[0]);
        repeatedTodo = todo.copyWith(
            id: Utils.generateTodoId(), dueDate: formattedDate, refId: _id);
        switch (todo.repeatType) {
          case "Daily":
            todoList.add(repeatedTodo);
            _todoDbHelper.insertTodo(repeatedTodo);
            break;
          case "Weekdays":
            if (isWeekday) {
              todoList.add(repeatedTodo);
              _todoDbHelper.insertTodo(repeatedTodo);
            }
            break;
          case "Weekends":
            if (!isWeekday) {
              todoList.add(repeatedTodo);
              _todoDbHelper.insertTodo(repeatedTodo);
            }
            break;
          case "Monthly":
            if (day == _day) {
              todoList.add(repeatedTodo);
              _todoDbHelper.insertTodo(repeatedTodo);
            }
            break;
        }
      }
      todos.addAll(todoList);
    }
  }

  updateTodoDoneById(String id, bool isDone) {
    int index = todos.indexWhere((todo) => todo.id == id);
    todos[index].done = isDone;

    _todoDbHelper = TodoDbHelper.instance;
    _todoDbHelper.updateTodoDone(todos[index].id,isDone);
  }

  setYearlyData(int year) {
    yearlyData.value = todos.where((todo) {
      List<String> splitDate = todo.dueDate.split(' ');
      String dueYear = splitDate[2];
      return year == int.parse(dueYear);
    }).toList();
  }

  getMonthlyCompletedTasksByYear(int year) {
    setYearlyData(year);
    List<double> _monthlyCompletedTasks = List.generate(12, (index) => 0);
    for (Todo todo in yearlyData) {
      List<String> splitDate = todo.dueDate.split(' ');
      String dueMonth = splitDate[1];
      if (todo.done) {
        _monthlyCompletedTasks[months.indexOf(dueMonth)]++;
      }
    }
    return _monthlyCompletedTasks;
  }

  getMonthlyPendingTasksByYear(int year) {
    List<double> _monthlyPendingTasks = List.generate(12, (index) => 0);

    for (Todo todo in yearlyData) {
      List<String> splitDate = todo.dueDate.split(' ');
      String dueMonth = splitDate[1];
      if (!todo.done) {
        _monthlyPendingTasks[months.indexOf(dueMonth)]++;
      }
    }
    return _monthlyPendingTasks;
  }

  removeTodo(String id) {
    int index = todos.indexWhere((todo) => todo.id == id);
    todos.removeAt(index);
    _todoDbHelper = TodoDbHelper.instance;
    _todoDbHelper.deleteTodo(id);
  }

  addSubtask(Subtask subtask) {
    _subtaskDbHelper = SubtaskDbHelper.instance;
    subtasks.add(subtask);
    _subtaskDbHelper.insertSubtask(subtask);
  }

  updateSubtask(Subtask subtask) {
    _subtaskDbHelper = SubtaskDbHelper.instance;
    int index = subtasks.indexWhere((s) => s.id == subtask.id);
    subtasks[index] = subtask;
    _subtaskDbHelper.updateSubtask(subtask);
  }

  updateSubtaskName(String id,String name){
    _subtaskDbHelper = SubtaskDbHelper.instance;
    int index = subtasks.indexWhere((s) => s.id == id);
    subtasks[index].name = name;
    _subtaskDbHelper.updateSubtaskName(id,name);
  }

  updateSubtaskDone(String id, bool isDone){
    _subtaskDbHelper = SubtaskDbHelper.instance;
    int index = subtasks.indexWhere((s) => s.id == id);
    subtasks[index].done = isDone;
    _subtaskDbHelper.updateSubtaskDone(id, isDone);
  }

  void deleteSubtask(String id){
    _subtaskDbHelper = SubtaskDbHelper.instance;
    int index = subtasks.indexWhere((s) => s.id == id);
    subtasks.removeAt(index);
    _subtaskDbHelper.deleteSubtask(id);
  }

  getAllSubtasks() async {
    _subtaskDbHelper = SubtaskDbHelper.instance;
    await _subtaskDbHelper.getAllSubtasks().then((value) {
      subtasks = value;
      if (kDebugMode) {
        print("SUBTASKS LIST : \n");
        for (var subtasks in subtasks) {
          print(subtasks.name);
        }
      }
    });
  }

  List<Subtask> getSubtasksByTodoId(Todo todo) {
    List<Subtask> _subtaskList = [];
    _subtaskList = subtasks
        .where((subtask) =>
            (subtask.todoId == todo.id) || (subtask.todoId == todo.refId))
        .toList();
    return _subtaskList;
  }
}
