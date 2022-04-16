import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:note_taker/components/components.dart';
import 'package:note_taker/models/models.dart';
import 'package:note_taker/repository/user_repository.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/utils/validators.dart';
import 'package:note_taker/views/widgets/widgets.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final UserRepository _userRepository = UserRepository();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPwdController = TextEditingController();
  late PageController _pageController;

  int _imgIndex = 0;

  double pageOffset = 0.0;
  @override
  initState() {
    super.initState();
    _pageController = PageController(initialPage: 0)
      ..addListener(() {
        setState(() {
          pageOffset = _pageController.page!;
        });
      });
  }

  _getHeader() {
    return Expanded(
        flex: 2,
        child: Container(
          alignment: Alignment.centerLeft,
          child: const Text(
            'REGISTER',
            style: TextStyle(
                fontFamily: 'PermanentMarker',
                color: Colors.white,
                fontSize: 30.0),
          ),
        ));
  }

  _getAvatars() {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0.0),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(CircleBorder())),
              onPressed: () {
                setState(() {
                  if (_pageController.page != 0.0) {
                    _pageController.previousPage(
                        duration:
                            const Duration(milliseconds: kAnimateDurationMs),
                        curve: Curves.easeOutCubic);
                  }
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 5.0),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: kIconColor,
                  size: kIconSize * 0.6,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Container(
            alignment: Alignment.topCenter,
            height: 100.0,
            width: 100.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50.0),
              border: Border.all(width: 3, color: Colors.white),
            ),
            child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: kAvatars.length,
                clipBehavior: Clip.antiAlias,
                itemBuilder: (context, index) {
                  _imgIndex = index;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 0.0),
                    child: CircleAvatar(
                      radius: 50.0,
                      foregroundImage:
                          AssetImage('assets/avatars/${kAvatars[index]}.png'),
                      backgroundColor: Colors.white,
                    ),
                  );
                }),
          ),
          const SizedBox(width: 10.0),
          Container(
            alignment: Alignment.center,
            height: 50.0,
            width: 50.0,
            child: ElevatedButton(
              style: ButtonStyle(
                  elevation: MaterialStateProperty.all(0.0),
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  shape: MaterialStateProperty.all(CircleBorder())),
              onPressed: () {
                setState(() {
                  if (_pageController.page != 9.0) {
                    _pageController.nextPage(
                        duration:
                            const Duration(milliseconds: kAnimateDurationMs),
                        curve: Curves.easeOutCubic);
                  }
                });
              },
              child: const Icon(
                Icons.arrow_forward_ios,
                color: kIconColor,
                size: kIconSize * 0.6,
              ),
            ),
          ),
        ]);
  }

  _getTextFields() {
    return Expanded(
      flex: 6,
      child: ListView(
        children: [
          CustomTextFormField(
            hintText: 'Name',
            inputType: TextInputType.text,
            controller: _nameController,
            imgUrl: kNameImg,
          ),
          const SizedBox(
            height: 30.0,
          ),
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
          const SizedBox(
            height: 30.0,
          ),
          CustomTextFormField(
            hintText: 'Confirm Password',
            inputType: TextInputType.visiblePassword,
            controller: _confirmPwdController,
            obscureText: true,
            imgUrl: kPwdImg,
          ),
          const SizedBox(
            height: 30.0,
          ),
        ],
      ),
    );
  }

  _getSubmitButton() {
    return CustomElevatedButton(
      label: 'Register',
      onPressed: () {
        String _name = _nameController.text;
        String _email = _emailController.text;
        String _pwd = _passwordController.text;
        String _confirmPwd = _confirmPwdController.text;
        final _isValid = Validators.validateRegister(
            context, _name, _email, _pwd, _confirmPwd);
        if (_isValid) {
          User _user = User(
              name: _name,
              image: kAvatars[_imgIndex],
              email: _email,
              password: _pwd);
          _user.setUserId(Utils.generateUserId(_name));
          Utils.checkInternetConnection(context).then((isConnected) => {
            if(isConnected){
              _userRepository.addUser(_user).then((value) => {
            if (value)
              {
                CustomSnackbar.buildSnackBar(
                  context: context,
                  content: 'Account register successful!',
                  contentColor: Colors.teal,
                  bgColor: Colors.teal.shade100,
                ),
                Future.delayed(const Duration(milliseconds: 300), () {
                  Get.offNamed('/login', preventDuplicates: false);
                })
              }
            else
              {
                CustomSnackbar.buildSnackBar(
                  context: context,
                  content: 'Account already exists!',
                  contentColor: Colors.red,
                  bgColor: Colors.red.shade100,
                ),
              }
          }),
            }else{
              CustomSnackbar.buildSnackBar(
                context: context,
                content: 'Check your internet connection!',
                contentColor: Colors.red,
                bgColor: Colors.red.shade100,
              ),
            }
          });
        }
      },
    );
  }

  _getLink() {
    return Expanded(
      flex: 1,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const Text(
            'Already have an account?',
            style: kBodyTextStyle,
          ),
          GestureDetector(
            onTap: () => Get.back(closeOverlays: true),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Text(
                    'Log in',
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
                ]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: BackgroundRegister(color: Theme.of(context).scaffoldBackgroundColor),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35.0),
          child: Column(children: [
            _getHeader(),
            _getAvatars(),
            _getTextFields(),
            _getSubmitButton(),
            const SizedBox(
              height: 20.0,
            ),
            _getLink(),
          ]),
        ),
      ),
    );
  }
}
