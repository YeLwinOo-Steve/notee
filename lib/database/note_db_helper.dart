import 'package:flutter/foundation.dart';
import 'package:note_taker/models/models.dart';
import 'package:sqflite/sqflite.dart';
import 'tables/tables.dart';

class NoteDbHelper {
  static final NoteDbHelper instance = NoteDbHelper._();
  static Database? _database;

  NoteDbHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDb('$noteTable.db');
    return _database!;
  }

  Future<Database> _initDb(String filePath) async {
    var dir = await getDatabasesPath();
    var path = dir + filePath;
    var database = openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
          create table $noteTable (
           ${NoteFields.id} text primary key,
           ${NoteFields.title} text,
           ${NoteFields.body} text,
           ${NoteFields.categoryId} text not null,
           ${NoteFields.dateTimeCreated} text,
           ${NoteFields.dateTimeEdited} text
          )        
        ''');
    });
    return database;
  }

  void insertNote(Note note) async{
    var db = await database;
    var result = await db.insert(noteTable, note.toJson());
    if (kDebugMode) {
      print("Insert Note : $result");
    }
  }
  
  void updateNote(Note note) async{
    var db = await database;
    var result = await db.update(noteTable, note.toJson(),where: '${NoteFields.id}=?',whereArgs: [note.id]);
    if(kDebugMode){
      print("Update Note : $result");
    }
  }

  void deleteNote(String id) async{
    var db = await database;
    var result = await db.delete(noteTable, where: '${NoteFields.id}=?',whereArgs: [id]);
    if(kDebugMode){
      print("Delete Note : $result");
    }
  }

  Future<List<Note>> getAllNotes() async{
    var db = await database;
    var queries = await db.query(noteTable);
    if(kDebugMode){
      print("Get All Notes : $queries");
    }
    List<Note> notes = [];
    for(var query in queries){
      notes.add(Note.fromJson(query));
    }
    return notes;
  }
}
