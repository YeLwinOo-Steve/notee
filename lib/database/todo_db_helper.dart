import 'dart:convert';
import 'dart:io';

import 'package:note_taker/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'tables/tables.dart';

class TodoDbHelper {
  static final TodoDbHelper instance = TodoDbHelper._();
  static Database? _database;
  TodoDbHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb('$todoTable.db');
    return _database!;
  }

  Future<Database> _initDb(String filePath) async {
    var dir = await getDatabasesPath();
    var path = dir + filePath;
    var database = openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
                create table $todoTable(
                  ${TodoFields.id} text primary key not null,
                  ${TodoFields.refId} text,
                  ${TodoFields.task} text not null,
                  ${TodoFields.dueDate} text not null,
                  ${TodoFields.done} integer not null,
                  ${TodoFields.reminderTime} text not null,
                  ${TodoFields.repeatType} text not null,
                  ${TodoFields.note} text,
                  ${TodoFields.dateTimeCreated} text
                )
      ''');
    });
    return database;
  }

  void insertTodo(Todo todo) async {
    var db = await database;
    var result = await db.insert(todoTable, todo.toJson());
    if (kDebugMode) {
      print("Insert Todo : $result");
    }
  }

  void deleteTodo(String id) async {
    var db = await database;
    var result = await db
        .delete(todoTable, where: '${TodoFields.id}=?', whereArgs: [id]);
    if (kDebugMode) {
      print("Delete Todo : $result");
    }
  }

  void updateTodo(Todo todo) async {
    var db = await database;
    var result = await db.update(todoTable, todo.toJson(),
        where: '${TodoFields.id}=?', whereArgs: [todo.id]);
    if (kDebugMode) {
      print("Update Todo : $result");
    }
  }

  void updateTodoDone(String id, bool isDone) async {
    var db = await database;
    int done = isDone ? 1 : 0;
    var result = await db.rawUpdate(
        'UPDATE $todoTable SET ${TodoFields.done}=? where ${TodoFields.id}=?',
        [done, id]);
    if (kDebugMode) {
      print("Update Todo DONE : $result");
    }
  }

  Future<List<Todo>> getAllTodos() async {
    var db = await database;
    List<Todo> todoList = [];
    var queries = await db.query(todoTable);
    if (kDebugMode) {
      var dir = await getDatabasesPath();
      var path = dir + '$todoTable.db';
      var file = File(path);
      final size = await file.length();
      print("DATABASE SIZE : $size");
    }
    print("Get All Todos : ");
    for (var query in queries) {
      print(query["id"]);
      print(query["refId"]);
      print(query["task"]);
      print(query["repeatType"]);
      print(query["dueDate"]);
      todoList.add(Todo.fromJson(query));
    }
    return todoList;
  }
}
