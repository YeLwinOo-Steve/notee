import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/utils/validators.dart';
import 'package:note_taker/views/widgets/widgets.dart';

import '../pages.dart';

class NoteManagerPage extends StatefulWidget {
  NoteManagerPage({Key? key, this.note}) : super(key: key);
  Note? note;

  @override
  State<NoteManagerPage> createState() => _NoteManagerPageState();
}

class _NoteManagerPageState extends State<NoteManagerPage> {
  String id = "";
  late Note note;
  bool isEdit = false;
  String appBarTitle = 'New Note';
  final catController = Get.find<CategoryController>();
  final noteController = Get.find<NoteController>();
  late Category _selectedCat;
  int _selectedCatIndex = 1;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  bool _isDarkTheme = false;

  @override
  void initState() {
    super.initState();
    _isDarkTheme = Utils.checkTheme();
    setMode();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void setMode() {
    setState(() {
      if (widget.note != null) {
        note = widget.note!;
        isEdit = true;
        id = note.id;
        appBarTitle = 'Edit Note';
        _titleController.text = note.title;
        Category cat = catController.getCategoryById(note.categoryId);
        _selectedCat = cat;
        _selectedCatIndex = catController.categoryList.indexOf(_selectedCat);
        _contentController.text = note.body;
      } else {
        _selectedCat = catController.categoryList[1];
      }
    });
  }

  onSave() {
    String title = _titleController.text;
    String content = _contentController.text;
    if (Validators.validateNewNote(title, content)) {
      if (isEdit) {
        Note editedNote = Note(
            id: id,
            categoryId: _selectedCat.id,
            title: title,
            body: content,
            dateTimeCreated: note.dateTimeCreated,
            dateTimeEdited: Utils.formatDate(DateTime.now()));
        noteController.updateNote(editedNote);
      } else {
        Note newNote = Note(
          id: Utils.generateNoteId(),
          categoryId: _selectedCat.id,
          title: title,
          body: content,
          dateTimeCreated: Utils.formatDate(DateTime.now()),
        );
        noteController.addNote(newNote);
      }

      CustomSnackbar.buildSnackBar(
        context: context,
        content: isEdit
            ? 'Note edited successfully!'
            : 'New note created successfully!',
        contentColor: Colors.teal,
        bgColor: Colors.teal.shade100,
      );
      Future.delayed(const Duration(milliseconds: kAnimateDurationMs - 100),
          () async {
        Get.offNamedUntil('/home', (route) => false);
        // Get.offNamed('/home', preventDuplicates: false);
      });
    } else {
      CustomSnackbar.buildSnackBar(
        context: context,
        content: 'Please fill Note first!',
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
                    noteController.deleteNote(id);
                    Future.delayed(const Duration(milliseconds: 300), () {
                      CustomSnackbar.buildSnackBar(
                        context: context,
                        content: 'Note deleted successfully!',
                        contentColor: Colors.teal,
                        bgColor: Colors.teal.shade100,
                      );
                    });
                    Future.delayed(
                        const Duration(milliseconds: kAnimateDurationMs - 100),
                        () {
                      Get.offNamedUntil('/home', (route) => false);
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
                  "Delete Note",
                  style: kTitleTextStyle,
                ),
              ),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Delete this note?',
                    style: kBodyTextStyle.copyWith(
                        color: kRedColor, letterSpacing: 1.3, fontSize: 17),
                  ),
                ],
              ),
            );
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          appBarTitle,
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
        actions: [
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
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 10.0, bottom: 5.0),
              child: TextField(
                cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
                cursorWidth: 4.0,
                cursorRadius: const Radius.circular(20.0),
                style: _isDarkTheme
                    ? kTitleTextStyle.copyWith(
                        color: kPrimaryColor,
                        height: 1.4,
                      )
                    : kTitleTextStyle.copyWith(
                        height: 1.4,
                      ),
                controller: _titleController,
                minLines: 1,
                maxLines: null,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(5.0),
                    hintText: 'Title',
                    hintStyle: TextStyle(
                        color: _isDarkTheme ? kPrimaryColor : kTextColor)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Divider(
                thickness: 0.5,
                color: _isDarkTheme ? kPrimaryColor : kIconColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: 50.0,
                child: CategoryListView(
                  selectedCatIndex: _selectedCatIndex,
                  onSelect: (Category selectedCat) {
                    _selectedCat = selectedCat;
                  },
                  isEdit: true,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50.0),
              child: Divider(
                thickness: 0.5,
                color: _isDarkTheme ? kPrimaryColor : kIconColor,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
              child: TextField(
                cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
                cursorWidth: 3.0,
                cursorRadius: const Radius.circular(20.0),
                style: TextStyle(
                    fontSize: 19.0,
                    height: 1.4,
                    color: _isDarkTheme ? kPrimaryColor : kTextColor),
                autofocus: false,
                controller: _contentController,
                minLines: 5,
                maxLines: null,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(5.0),
                    hintText: 'Enter your note 📝',
                    hintStyle: TextStyle(
                        color: _isDarkTheme ? kPrimaryColor : kTextColor)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
