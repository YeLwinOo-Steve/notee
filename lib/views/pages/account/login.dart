import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:get/get.dart';

import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/repository/user_repository.dart';
import 'package:note_taker/shared_data/shared_data.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/utils/validators.dart';
import 'package:note_taker/views/widgets/widgets.dart';

import '../pages.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final UserRepository _userRepository = UserRepository();
  final accountController = Get.find<AccountController>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  _getHeader() {
    return Expanded(
        flex: 2,
        child: Container(
          alignment: Alignment.bottomLeft,
          child: const Text(
            'LOG IN',
            style: TextStyle(
                fontFamily: 'PermanentMarker',
                color: Colors.white,
                fontSize: 30.0),
          ),
        ));
  }

  _getTextFields() {
    return Expanded(
      flex: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomTextFormField(
            hintText: 'Email',
            inputType: TextInputType.emailAddress,
            controller: _emailController,
            imgUrl: kEmailImg,
          ),
          const SizedBox(
            height: 30.0,
          ),
          CustomTextFormField(
            hintText: 'Password',
            inputType: TextInputType.visiblePassword,
            controller: _passwordController,
            obscureText: true,
            imgUrl: kPwdImg,
          ),
        ],
      ),
    );
  }

  _getSubmitButton() {
    return CustomElevatedButton(
      label: 'Log In',
      onPressed: () {
        String _email = _emailController.text;
        String _pwd = _passwordController.text;
        bool _isValid = Validators.validateLogin(_email, _pwd);
        if (_isValid) {
          Utils.checkInternetConnection(context).then((isConnected) {
            if (isConnected) {
              _userRepository.getUser(_email, _pwd).then((existingUser) {
                if (existingUser.isNotEmpty) {
                  User _user = User.fromSnapshot(existingUser[0]);
                  SharedData.setUserData(_user);
                  accountController.setLoggedIn = true;
                  Get.offAll(() => HomePage(),
                      duration: const Duration(
                          milliseconds: kAnimateDurationMs + 100),
                      transition: Transition.size,
                      curve: Curves.easeInOut);
                } else {
                  CustomSnackbar.buildSnackBar(
                    context: context,
                    content: 'Invalid email or password!',
                    contentColor: Colors.red,
                    bgColor: Colors.red.shade100,
                  );
                }
              });
            } else {
              CustomSnackbar.buildSnackBar(
                context: context,
                content: 'Check your internet connection!',
                contentColor: Colors.red,
                bgColor: Colors.red.shade100,
              );
            }
          });
        } else {
          CustomSnackbar.buildSnackBar(
            context: context,
            content: 'Please fill all fields!',
            contentColor: Colors.red,
            bgColor: Colors.red.shade100,
          );
        }
      },
    );
  }

  _getLink() {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textBaseline: TextBaseline.ideographic,
        children: [
          const Text(
            'Forgot Password?',
            style: kBodyTextStyle,
          ),
          OpenContainer(
              openBuilder: (context, _) => const Register(),
              transitionDuration:
                  const Duration(milliseconds: kAnimateDurationMs),
              closedElevation: 0.0,
              openColor: Colors.white,
              openElevation: 0.0,
              closedColor: Colors.transparent,
              closedBuilder: (context, openContainer) {
                return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text(
                        'Register',
                        style: kSmallTitleTextStyle,
                      ),
                      SizedBox(
                        width: 3.0,
                      ),
                      Icon(
                        Icons.arrow_right_alt_sharp,
                        color: kIconColor,
                        size: kIconSize,
                      ),
                    ]);
              })
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter:
            BackgroundLogin(color: Theme.of(context).scaffoldBackgroundColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: Column(
            children: [
              _getHeader(),
              _getTextFields(),
              _getSubmitButton(),
              _getLink()
            ],
          ),
        ),
      ),
    );
  }
}
