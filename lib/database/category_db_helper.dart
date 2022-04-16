import 'package:flutter/foundation.dart' as foundation;
import 'package:note_taker/models/models.dart';
import 'package:sqflite/sqflite.dart';
import 'tables/tables.dart';

class CategoryDbHelper {
  static final CategoryDbHelper instance = CategoryDbHelper._();
  static Database? _database;
  CategoryDbHelper._();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb('$categoryTable.db');
    return _database!;
  }

  Future<Database> _initDb(String filePath) async {
    var dir = await getDatabasesPath();
    var path = dir + filePath;
    var database = openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute('''
          create table $categoryTable(
          ${CategoryFields.id} text primary key not null,
          ${CategoryFields.name} text not null,
          ${CategoryFields.color} integer not null
          )
          ''');
    });
    return database;
  }

  void insertCategory(Category category) async {
    var db = await database;
    var result = await db.insert(categoryTable, category.toJson());
    if(foundation.kDebugMode){
      print("Insert Category: $result");
    }
  }

  Future<List<Category>> getAllCategories() async{
    var db = await database;
    var queries = await db.query(categoryTable);
    if(foundation.kDebugMode){
      print("Get All Categories : $queries");
    }
    List<Category> categories = [];
    for(var query in queries){
      categories.add(Category.fromJson(query));
    }
    return categories;
  }
}
