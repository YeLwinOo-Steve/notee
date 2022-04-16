import 'package:flutter/foundation.dart' as foundation;
import 'package:get/get.dart';
import 'package:note_taker/components/components.dart';
import 'package:note_taker/database/category_db_helper.dart';
import 'package:note_taker/models/category.dart';
import 'package:note_taker/models/enums/category_colors.dart';
import 'package:note_taker/models/enums/default_cat_names.dart';
import 'package:note_taker/utils/utils.dart';

class CategoryController extends GetxController
    with StateMixin<List<Category>> {
  List<Category> categoryList = <Category>[].obs;
  var selectedCat = 0.obs;
  late CategoryDbHelper _dbHelper;
  @override
  void onInit() {
    super.onInit();
    getAllCategories();
  }

  void fillCategoryList() async {
    _dbHelper = CategoryDbHelper.instance;
    final List<Category> cat = List.generate(
      6,
      (index) => Category(
          id: Utils.generateCategoryId(),
          name: Utils.getCategoryNames(DEFAULT_CAT_NAMES.values[index]),
          color: index),
    );
    for(var c in cat){
      _dbHelper.insertCategory(c);
    }
    categoryList = cat;
  }

  int get categoryListLength => categoryList.length;

  set selectedCatIndex(int index) => selectedCat.value = index;

  Future<void> getAllCategories() async {
    _dbHelper = CategoryDbHelper.instance;
    try {
        await _dbHelper.getAllCategories().then((value) {
          categoryList = value;
          if (foundation.kDebugMode) {
            print("CATEGORY LIST : \n");
            for (var category in categoryList) {
              print(category.name);
            }
          }
          if (categoryList.isNotEmpty) {
            change(categoryList, status: RxStatus.success());
          } else {
            fillCategoryList();
            // change([],status: RxStatus.empty());
          }
        });
    } catch (error) {
      change(null, status: RxStatus.error('Something went wrong'));
    }
  }

  addCategory(Category category) {
    _dbHelper = CategoryDbHelper.instance;
    categoryList.add(category);
    _dbHelper.insertCategory(category);
  }

  getCategoryById(String id) {
    Category cat = categoryList.singleWhere((c) => c.id == id);
    return cat;
  }

  bool checkCategory(Category category) {
    int index = categoryList.indexWhere(
        (cat) => cat.name.toLowerCase() == category.name.toLowerCase());
    return index == -1 ? false : true;
  }

  removeCategory(String id) {
    categoryList.removeWhere((category) => category.id == id);
  }
}
