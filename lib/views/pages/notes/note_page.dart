import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animations/animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/service/notifications.dart';
import 'package:note_taker/views/pages/pages.dart';
import 'package:note_taker/views/widgets/widgets.dart';

import '../../../utils/utils.dart';

class NotePage extends StatefulWidget {
  NotePage({Key? key}) : super(key: key);

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final catController = Get.find<CategoryController>();
  final noteController = Get.find<NoteController>();

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  final ScrollController _noteScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String searchNote = '';
  late Category _selectedCat;
  bool _isSearchClose = false;
  List<Note> notes = [];
  List<Note> searchNotes = [];

  @override
  void initState() {
    super.initState();
    createNotifications();
    _selectedCat = catController.categoryList[0];
    notes = noteController.noteList;
    _noteScrollController.addListener(() {
      setState(() {
        _isSearchClose = _noteScrollController.offset > 50 ? true : false;
      });
    });
  }

  void createNotifications() async{
    // await cancelScheduledNotifications();
    AwesomeNotifications()
        .listScheduledNotifications()
        .then((scheduledNotifications) {
      if (scheduledNotifications.isEmpty) {
        notificationsHandler();
        for (int i = 1; i <= 7; i++) {
          createReminderNotification(i);
        }
      }
    });
  }

  @override
  void dispose() {
    AwesomeNotifications().actionSink.close();
    super.dispose();
  }

  void notificationsHandler() {
    AwesomeNotifications().actionStream.listen((notification) {
      if (notification.channelKey == 'basic_channel' && Platform.isIOS) {
        AwesomeNotifications().getGlobalBadgeCounter().then(
              (value) =>
                  AwesomeNotifications().setGlobalBadgeCounter(value - 1),
            );
      }

      Get.offAll(HomePage(
        pageIndex: 1,
      ));
    });
  }

  List<Note> getNotesByCat() {
    List<Note> noteList = [];
    noteList.addAll(noteController.noteList.where((note) {
      Category cat = catController.getCategoryById(note.categoryId);
      return cat == _selectedCat;
    }).toList());
    return noteList;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    IconButton addNewCategory() {
      return IconButton(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        iconSize: kIconSize + 8,
        onPressed: () => _globalKey.currentState?.showBottomSheet(
          (context) => const CategoryBottomSheet(),
          elevation: 20.0,
          backgroundColor: Colors.transparent,
          constraints: BoxConstraints(
            maxWidth: size.width - 10.0,
            maxHeight: 350.0,
          ),
        ),
        icon: const Icon(
          Icons.add_circle,
          color: kIconColor,
        ),
      );
    }

    void onSearch(String str) {
      searchNote = str.toLowerCase();
      searchNotes = [];
      searchNotes.addAll(noteController.noteList.where((e) =>
          (e.title.toLowerCase().contains(searchNote) ||
              e.body.toLowerCase().contains(searchNote))));
    }

    ///Search bar
    Form searchBar() {
      return Form(
        child: TextFormField(
          textAlignVertical: TextAlignVertical.center,
          keyboardType: TextInputType.text,
          controller: _searchController,
          autofocus: false,
          onChanged: (val) {
            setState(() {
              if (val.isNotEmpty) {
                onSearch(val.trim());
              } else {
                notes = noteController.noteList;
              }
            });
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(10.0),
            border: kOutlineInputBorder,
            enabledBorder: kOutlineInputBorder,
            focusedBorder: kOutlineInputBorder,
            hintText: 'Search',
            hintStyle: kHintTextStyle,
            prefixIcon: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(kSearchImg, width: 40.0, height: 40.0),
            ),
          ),
          style: kBodyTextStyle,
        ),
      );
    }

    buildNoteList() {
      return Expanded(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 70.0,
              child: Row(children: [
                Expanded(
                  flex: 8,
                  child: CategoryListView(
                    selectedCatIndex: 0,
                    onSelect: (Category selectedCat) {
                      _selectedCat = selectedCat;
                      setState(() {
                        notes = [];
                        if (_selectedCat.name == "All") {
                          notes = noteController.noteList;
                        } else {
                          notes = getNotesByCat();
                        }
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: addNewCategory(),
                )
              ]),
            ),
            notes.isEmpty
                ? const Expanded(child: EmptyNotePage())
                : Expanded(
                    child: MasonryGridView.count(
                    controller: _noteScrollController,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0, bottom: 20.0),
                    crossAxisCount: 2,
                    mainAxisSpacing: 5.0,
                    crossAxisSpacing: 5.0,
                    physics: const BouncingScrollPhysics(),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final Category category =
                          catController.getCategoryById(note.categoryId);
                      final titleHeight = Utils.textHeight(
                          note.title, kSmallTitleTextStyle, 2, context);
                      final bodyHeight = Utils.textHeight(
                          note.body, kBodyTextStyle, 4, context);

                      return SizedBox(
                        height: titleHeight + bodyHeight + 60,
                        key: Key(note.id),
                        child: OpenContainer(
                          openBuilder: (context, _) =>
                              NoteManagerPage(note: note),
                          transitionDuration:
                              const Duration(milliseconds: kAnimateDurationMs),
                          closedShape: RoundedRectangleBorder(
                            side: BorderSide(
                                color: Utils.getCategoryColors(
                                    CATEGORY_COLORS.values[category.color])),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          closedColor: Colors.white,
                          closedBuilder: (context, openContainer) =>
                              noteItem(index, note, category),
                        ),
                      );
                    },
                  )),
            // ),
          ],
        ),
      );
    }

    buildSearchNoteList() {
      return Expanded(
        child: (searchNotes.isEmpty
            ? const EmptyNotePage()
            : MasonryGridView.count(
                controller: _noteScrollController,
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 20.0),
                crossAxisCount: 2,
                mainAxisSpacing: 5.0,
                crossAxisSpacing: 5.0,
                physics: const BouncingScrollPhysics(),
                itemCount: searchNotes.length,
                itemBuilder: (context, index) {
                  final note = searchNotes[index];
                  final Category category =
                      catController.getCategoryById(note.categoryId);
                  final titleHeight = Utils.textHeight(
                      note.title, kSmallTitleTextStyle, 2, context);
                  final bodyHeight =
                      Utils.textHeight(note.body, kBodyTextStyle, 4, context);

                  return SizedBox(
                    height: titleHeight + bodyHeight + 60,
                    key: Key(note.id),
                    child: OpenContainer(
                      openBuilder: (context, _) => NoteManagerPage(note: note),
                      transitionDuration:
                          const Duration(milliseconds: kAnimateDurationMs),
                      closedShape: RoundedRectangleBorder(
                        side: BorderSide(
                            color: Utils.getCategoryColors(
                                CATEGORY_COLORS.values[category.color])),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      closedColor: Colors.white,
                      closedBuilder: (context, openContainer) =>
                          noteItem(index, note, category),
                    ),
                  );
                },
              )),
      );
    }

    return Scaffold(
      key: _globalKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
          child: Column(children: [
        const SizedBox(height: 5.0),
        AnimatedOpacity(
          opacity: _isSearchClose ? 0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            curve: Curves.easeInOut,
            height: _isSearchClose ? 0 : 50.0,
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: searchBar(),
            ),
          ),
        ),
        _searchController.text.isNotEmpty
            ? buildSearchNoteList()
            : buildNoteList(),
      ])),
      floatingActionButton: Card(
        margin: const EdgeInsets.all(0.0),
        elevation: 20.0,
        shadowColor: kIconColor,
        shape: kRoundedRectangleBorder,
        color: kIconColor,
        child: OpenContainer(
          transitionType: ContainerTransitionType.fadeThrough,
          transitionDuration: const Duration(milliseconds: kAnimateDurationMs),
          openBuilder: (context, _) => NoteManagerPage(),
          closedShape: const CircleBorder(),
          openColor: Theme.of(context).primaryColor,
          middleColor: Theme.of(context).primaryColor,
          closedColor: kIconColor,
          closedBuilder: (context, openContainer) => FloatingActionButton(
              mini: true,
              onPressed: openContainer,
              backgroundColor: Colors.transparent,
              elevation: 20.0,
              child: Image.asset(kAddNoteImg, width: 30.0, height: 30.0)),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
    );
  }

  ///Note items in grid view
  noteItem(int index, Note note, Category category) {
    int colorIndex = category.color;
    return Card(
        shadowColor: Colors.transparent,
        color: Utils.getCategoryColors(CATEGORY_COLORS.values[colorIndex])
            .withOpacity(0.05),
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.title.isNotEmpty)
                  Text(note.title,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: kSmallTitleTextStyle),
                note.body.isNotEmpty
                    ? Expanded(
                        child: Text(
                          note.body,
                          maxLines: 4,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: kBodyTextStyle.copyWith(height: 1.6),
                        ),
                      )
                    : Text(
                        "●●" * 2,
                        style: const TextStyle(
                            color: kTextColor, letterSpacing: 1.5),
                      ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: SizedBox(
                    height: 25.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(
                          Icons.date_range_rounded,
                          size: kSmallIconSize,
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 5.0),
                        Text(
                          note.dateTimeCreated,
                          style:
                              kSmallTextStyle.copyWith(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
        ));
  }
}
