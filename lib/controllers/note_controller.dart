import 'package:flutter/foundation.dart' as foundation;
import 'package:get/get.dart';
import 'package:note_taker/controllers/controllers.dart';
import 'package:note_taker/database/note_db_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../models/models.dart';

class NoteController extends GetxController with StateMixin<List<Note>>{
  List<Note> noteList = <Note>[].obs;
  int get noteListLength => noteList.length;
  late CategoryController catController;
  late NoteDbHelper _dbHelper;

  @override
  void onInit(){
    getAllNotes();
    super.onInit();
  }

  addNote(Note newNote) async{
    _dbHelper = NoteDbHelper.instance;
    noteList.insert(0, newNote);

    _dbHelper.insertNote(newNote);
  }

  Future<void> getAllNotes() async {
    _dbHelper = NoteDbHelper.instance;
    try{
      change(null, status: RxStatus.loading());
        await _dbHelper.getAllNotes().then((value) {
          noteList = value;
          if(foundation.kDebugMode){
            print("NOTE LIST : \n");
            for(var note in noteList){
              print(note.id);
            }
          }
          if(noteList.isNotEmpty){
            change(noteList,status: RxStatus.success());
          }else{
            change([],status: RxStatus.empty());
          }
        });
    }catch(error){
        change(null, status: RxStatus.error('Something went wrong'));
    }
  }

  updateNote(Note editedNote) {
    _dbHelper = NoteDbHelper.instance;
    String id = editedNote.id;
    int index = noteList.indexWhere((note) => note.id == id);
    noteList[index] = editedNote;

    _dbHelper.updateNote(editedNote);
  }

  deleteNote(String id) {
    noteList.removeWhere((note) => note.id == id);
    _dbHelper = NoteDbHelper.instance;
    _dbHelper.deleteNote(id);
  }

  getNoteCountByCat(String catId){
    catController = Get.find<CategoryController>();
    int count = 0;
    for(Note note in noteList){
      Category category = catController.getCategoryById(note.categoryId);
      if(category.id == catId){
        count++;
      }
    }
    return count;
  }
}
