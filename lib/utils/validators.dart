import 'package:note_taker/controllers/controllers.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../views/widgets/widgets.dart';

class Validators{
  static bool validateNewNote(String title, String body){
    return (title.isNotEmpty || body.isNotEmpty) ? true : false;
  }

  static bool validateNewCategory(String name){
    final catController = Get.find<CategoryController>();
    int index = catController.categoryList.indexWhere((cat) => cat.name.toLowerCase() == name.toLowerCase());
    return (index != -1 || name.isEmpty) ? false : true;
  }

  static bool validateTask(String name){
    return (name.isNotEmpty) ? true : false;
  }
  static bool validateSubtask(String name){
   return (name.isNotEmpty) ? true : false;
  }

  static bool validateRegister(BuildContext context, String name, String email,String pwd,String confirmPwd){
    if(name.isEmpty || email.isEmpty || pwd.isEmpty || confirmPwd.isEmpty ) {
      CustomSnackbar.buildSnackBar(
        context: context,
        content: 'Please fill all fields!',
        contentColor: Colors.red,
        bgColor: Colors.red.shade100,
      );
      return false;
    }else{
      if(pwd != confirmPwd){
        CustomSnackbar.buildSnackBar(
          context: context,
          content: 'Passwords must be the same!',
          contentColor: Colors.red,
          bgColor: Colors.red.shade100,
        );
        return false;
      }
      bool isEmailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
      if(!isEmailValid){
        CustomSnackbar.buildSnackBar(
          context: context,
          content: 'Email is invalid!',
          contentColor: Colors.red,
          bgColor: Colors.red.shade100,
        );
        return false;
      }
      return true;
    }
  }

  static bool validateLogin(String email, String pwd){
    return (email.isEmpty || pwd.isEmpty) ? false : true;
  }

  static bool validateUserName(String name){
    return name.isNotEmpty;
  }

  static bool validateEmail(String email){
    return email.isNotEmpty;
  }

  static bool validateUpdatePassword(String pwd, String newPwd, String confirmPwd){
    return (pwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) ? false : true;
  }
}