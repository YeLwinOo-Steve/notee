import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/repository/user_repository.dart';
import 'package:note_taker/shared_data/shared_data.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/utils/validators.dart';

import 'package:note_taker/views/widgets/widgets.dart';

import '../../../components/components.dart';

class ChangePassword extends StatefulWidget {
  ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _userRepository = UserRepository();
  final _oldPwdController = TextEditingController();

  final _newPwdController = TextEditingController();

  final _confirmNewPwdController = TextEditingController();
  String _userId = '';
  String _oldPwd = '';
  @override
  void initState() {
    super.initState();
    SharedData.getUserId().then((value) {
      setState(() {
        _userId = value;
      });
    });
    SharedData.getUserPassword().then((value){
      setState(() {
        _oldPwd = value;
      });
    });
  }

  _getSubmitButton() {

    return SizedBox(
      width: 150.0,
      height: 50.0,
      child: CustomElevatedButton(
        label: 'Submit',
        onPressed: () {
          String _pwd = _oldPwdController.text;
          String _newPwd = _newPwdController.text;
          String _newConfirmPwd = _confirmNewPwdController.text;
          bool _isValid = Validators.validateUpdatePassword(_pwd, _newPwd ,_newConfirmPwd);
          if (_isValid) {
            if(_oldPwd != _pwd){
              CustomSnackbar.buildSnackBar(
                context: context,
                content: 'Wrong old password!',
                contentColor: Colors.red,
                bgColor: Colors.red.shade100,
              );
            }else{
              if(_newPwd != _newConfirmPwd){
                CustomSnackbar.buildSnackBar(
                  context: context,
                  content: 'New password and confirm password must be the same!',
                  contentColor: Colors.red,
                  bgColor: Colors.red.shade100,
                );
              }else{
                Utils.checkInternetConnection(context).then((isConnected) async {
                  if (isConnected) {
                    _userRepository.updatePassword(_userId, _newPwd);
                    SharedData.updatePassword(_newPwd);
                    CustomSnackbar.buildSnackBar(
                      context: context,
                      content: 'Password Update Successful!',
                      contentColor: Colors.teal,
                      bgColor: Colors.teal.shade100,
                    );
                    Get.back();
                  } else {
                    CustomSnackbar.buildSnackBar(
                      context: context,
                      content: 'Check your internet connection!',
                      contentColor: Colors.red,
                      bgColor: Colors.red.shade100,
                    );
                  }
                });
              }
            }
          } else {
            CustomSnackbar.buildSnackBar(
              context: context,
              content: 'Please fill all fields!',
              contentColor: Colors.red,
              bgColor: Colors.red.shade100,
            );
          }
        },
      ),
    );
  }

  _getCancelButton() {
    return SizedBox(
      width: 150.0,
      height: 50.0,
      child: CustomElevatedButton(
        label: 'Cancel',
        bgColor: Colors.blueGrey,
        onPressed: () {
          Get.back();
        },
      ),
    );
  }

  _getTextFields() {
    return Column(children: [
      CustomTextFormField(
        hintText: 'Old Password',
        inputType: TextInputType.visiblePassword,
        controller: _oldPwdController,
        obscureText: true,
        imgUrl: kPwdImg,
      ),
      const SizedBox(
        height: 30.0,
      ),
      CustomTextFormField(
        hintText: 'New Password',
        inputType: TextInputType.visiblePassword,
        controller: _newPwdController,
        obscureText: true,
        imgUrl: kPwdImg,
      ),
      const SizedBox(
        height: 30.0,
      ),
      CustomTextFormField(
        hintText: 'Confirm New Password',
        inputType: TextInputType.visiblePassword,
        controller: _confirmNewPwdController,
        obscureText: true,
        imgUrl: kPwdImg,
      ),
      const SizedBox(
        height: 50.0,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Change Password',
          style: TextStyle(color: kTextColor),
        ),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: const Icon(Icons.arrow_back_ios, color: kIconColor),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 30.0,
            ),
            _getTextFields(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [_getCancelButton(), _getSubmitButton()],
            ),
            const SizedBox(height: 50.0),
          ],
        ),
      ),
    );
  }
}
