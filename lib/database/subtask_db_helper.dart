import 'package:sqflite/sqflite.dart';
import 'package:note_taker/models/models.dart';
import 'package:flutter/foundation.dart';
import 'tables/tables.dart';

class SubtaskDbHelper {
  static final SubtaskDbHelper instance = SubtaskDbHelper._();
  static Database? _database;
  SubtaskDbHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb('$subtaskTable.db');
    return _database!;
  }

  Future<Database> _initDb(String filePath) async {
    var dir = await getDatabasesPath();
    var path = dir + filePath;
    var database =
        openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
        create table $subtaskTable(
        ${SubtaskFields.id} text primary key not null,
        ${SubtaskFields.name} text not null,
        ${SubtaskFields.done} integer not null,
        ${SubtaskFields.todoId} text not null
        
        )
      ''');
    });
    return database;
  }

// FOREIGN KEY(${SubtaskFields.todoId} REFERENCES $todoTable(${TodoFields.id})
  void insertSubtask(Subtask subtask) async {
    var db = await database;
    var result = await db.insert(subtaskTable, subtask.toJson());
    if (kDebugMode) {
      print("Insert Subtask : $result");
    }
  }

  void updateSubtask(Subtask subtask) async {
    var db = await database;
    var result = await db.update(subtaskTable, subtask.toJson(),
        where: '${SubtaskFields.id}=?', whereArgs: [subtask.id]);
    if (kDebugMode) {
      print("Update Subtask : $result");
    }
  }

  void updateSubtaskName(String id, String name) async {
    var db = await database;
    var result = await db.rawUpdate('Update $subtaskTable set ${SubtaskFields.name}=? where ${SubtaskFields.id}=?',[name,id]);
    if(kDebugMode){
      print("Update Subtask Name : $result");
    }
  }

  void updateSubtaskDone(String id, bool isDone) async {
    var db = await database;
    int done = isDone ? 1 : 0;
    var result = await db.rawUpdate('Update $subtaskTable set ${SubtaskFields.done}=? where ${SubtaskFields.id}=?',[done,id]);
    if(kDebugMode){
      print("Update Subtask Done : $result");
    }
  }

  void deleteSubtask(String id) async{
    var db = await database;
    var result = await db.delete(subtaskTable,where: '${SubtaskFields.id}=?',whereArgs: [id]);
    if(kDebugMode){
      print("Delete Subtask : $result");
    }
  }

  Future<List<Subtask>> getAllSubtasks() async {
    var db = await database;
    var queries = await db.query(subtaskTable);
    if (kDebugMode) {
      print("Get All Subtasks : $queries");
    }
    List<Subtask> subtasks = [];
    for (var query in queries) {
      subtasks.add(Subtask.fromJson(query));
    }
    return subtasks;
  }
}
