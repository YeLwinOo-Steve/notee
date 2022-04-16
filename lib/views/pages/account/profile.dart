import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:note_taker/components/components.dart';
import 'package:note_taker/controllers/controllers.dart';
import 'package:note_taker/repository/user_repository.dart';
import 'package:note_taker/shared_data/shared_data.dart';
import 'package:note_taker/utils/utils.dart';
import 'package:note_taker/utils/validators.dart';
import '../../widgets/widgets.dart';
import '../pages.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final UserRepository _userRepository = UserRepository();
  final accountController = Get.find<AccountController>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  static bool _isDarkTheme = false;
  static String _selectedTheme = 'light';
  static int _selectedSyncIndex = 0;

  bool _isLoggedIn = false;
  final String _version = '1.0.0+1 (alpha)';

  String _id = '', _name = '', _email = '', _image = '';
  @override
  initState() {
    super.initState();
    initiateData();
  }

  initiateData() {
    accountController.isLoggedIn.then((value) {
      setState(() {
        _isLoggedIn = value;
        SharedData.getUserId().then((id) {
          _id = id;
        });
        SharedData.getUserName().then((name) {
          _name = name;
          _nameController.text = _name;
        });
        SharedData.getUserEmail().then((email) {
          _email = email;
          _emailController.text = _email;
        });
        SharedData.getUserImage().then((image) {
          _image = image;
        });
      });
    });
    accountController.isDarkTheme.then((value) {
      setState(() {
        _isDarkTheme = value;
        _selectedTheme = _isDarkTheme ? 'dark' : 'light';
      });
    });
  }

  changeTheme() {
    setState(() {
      _isDarkTheme = !_isDarkTheme;
      if (_isDarkTheme) {
        Get.changeThemeMode(ThemeMode.dark);
        _selectedTheme = 'dark';
        accountController.setDarkTheme = true;
      } else {
        Get.changeThemeMode(ThemeMode.light);
        _selectedTheme = 'light';
        accountController.setDarkTheme = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 200.0,
            elevation: 0.0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            toolbarHeight: 70.0,
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios, color: kIconColor),
            ),
            actions: [
              const SizedBox(width: 5.0),
              Visibility(
                visible: _isLoggedIn,
                child: IconButton(
                  onPressed: () {
                    accountController.setLoggedIn = false;
                    SharedData.deleteUserData();
                    Get.back();
                  },
                  icon: Image.asset(
                    kLogoutImg,
                    fit: BoxFit.fitWidth,
                    color: kIconColor,
                  ),
                ),
              ),
              const SizedBox(width: 5.0)
            ],
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                double top = constraints.biggest.height;
                return FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 45.0, bottom: 15.0),
                  title: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          minRadius: 12.0,
                          maxRadius: 20.0,
                          backgroundColor: kPrimaryColor,
                          backgroundImage: AssetImage(
                            _isLoggedIn
                                ? 'assets/avatars/$_image.png'
                                : kUserImg,
                          ),
                        ),
                        const SizedBox(width: 10.0),
                        Visibility(
                          visible: _isLoggedIn,
                          child: AnimatedOpacity(
                            opacity: 1.0,
                            duration: const Duration(
                                milliseconds: kAnimateDurationMs),
                            child: AnimatedDefaultTextStyle(
                              style: TextStyle(
                                  color:
                                      (top > 100) ? Colors.white : kTextColor,
                                  fontSize: (top > 100) ? 14.0 : 16.0,
                                  fontWeight: (top > 100)
                                      ? FontWeight.bold
                                      : FontWeight.w500),
                              duration: const Duration(
                                  milliseconds: kAnimateDurationMs),
                              curve: Curves.easeInOut,
                              child: Text(
                                Utils.clipText(_name),
                              ),
                            ),
                          ),
                        ),
                      ]),
                  background: Image.asset(
                    kLandscapeImg,
                    fit: BoxFit.fill,
                  ),
                );
              },
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 0.0, bottom: 15.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Visibility(
                        visible: _isLoggedIn,
                        child: _accountInfo(),
                      ),
                      const SizedBox(height: 20.0),
                      _reports(),
                      const SizedBox(height: 20.0),
                      _changeThemeListTile(),
                      const SizedBox(height: 20.0),
                      Visibility(
                          visible: _isLoggedIn, child: _changePassword()),
                      // _syncData(),
                      Visibility(
                          visible: _isLoggedIn,
                          child: const SizedBox(height: 20.0)),
                      _privacyPolicy(),
                      const SizedBox(height: 20.0),
                      _aboutUs(),
                      const SizedBox(
                        height: 20.0,
                      ),
                      _appVersion(),
                      const SizedBox(height: 100.0),
                      Visibility(
                        visible: _isLoggedIn,
                        child: _deleteAccount(),
                      ),
                      Visibility(visible: !_isLoggedIn, child: _logIn()),
                    ],
                  ),
                )
              ],
            ),
          ),
        ]),
      ),
    );
  }

  _logIn() {
    return SizedBox(
      height: 50.0,
      width: double.infinity,
      child: CustomElevatedIconButton(
        label: 'Log In',
        fontSize: 18,
        iconData: Icons.login,
        iconSize: 28,
        bgColor: kIconColor,
        onPressed: () {
          Get.to(() => const Login(),
              preventDuplicates: false,
              curve: Curves.easeInOut,
              transition: Transition.circularReveal);
        },
      ),
    );
  }

  _accountInfo() {
    // double leftRightPadding = MediaQuery.of(context).size.width - MediaQuery.of(context).size.width *0.7 - 50.0;
    double leftRightPadding = 30;
    return Stack(
      children: [
        Align(
          alignment: Alignment.bottomCenter,
          child: ClipPath(
              clipper: AccountInfoClipper(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                // width: MediaQuery.of(context).size.width *0.7,
                width: double.infinity,
                color: kIconColor,
              )),
        ),
        Positioned(
          top: 50.0,
          left: MediaQuery.of(context).size.width / 5,
          child: Container(
            width: 150,
            height: 150,
            padding: const EdgeInsets.all(10.0),
            child: CircleAvatar(
              backgroundColor: Colors.teal.shade50,
              backgroundImage: AssetImage(
                'assets/avatars/$_image.png',
              ),
            ),
          ),
        ),
        Positioned(
          top: 100,
          right: leftRightPadding + 5,
          child: RotatedBox(
            quarterTurns: -1,
            child: Text(
              'Account',
              style: kTitleTextStyle.copyWith(
                color: Colors.white,
                letterSpacing: 3,
                fontSize: 30,
                shadows: <Shadow>[
                  const Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 5.0,
                    color: kPrimaryColor,
                  ),
                  const Shadow(
                    offset: Offset(4.0, 4.0),
                    blurRadius: 10.0,
                    color: kPrimaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
            left: leftRightPadding,
            right: leftRightPadding,
            bottom: 160.0,
            child: ListTile(
              contentPadding: const EdgeInsets.all(0.0),
              title: Text(
                _name,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: kBodyWhiteTextStyle.copyWith(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              trailing: IconButton(
                  padding: const EdgeInsets.all(10.0),
                  onPressed: () {
                    _editDialog(
                      title: 'Edit User Name',
                      controller: _nameController,
                      inputType: TextInputType.text,
                      onSave: () {
                        String _name = _nameController.text;
                        bool _isValid = Validators.validateUserName(_name);
                        if (_isValid) {
                          Utils.checkInternetConnection(context)
                              .then((isConnected) async {
                            if (isConnected) {
                              _userRepository.updateUserName(_id, _name);
                              SharedData.updateUserName(_name);
                              String newId = Utils.generateUserId(_name);
                              SharedData.updateUserId(newId);
                              _userRepository.updateUserId(_id, newId);
                              CustomSnackbar.buildSnackBar(
                                context: context,
                                content: 'User Name Update Successful!',
                                contentColor: Colors.teal,
                                bgColor: Colors.teal.shade100,
                              );
                              Get.back();
                              Get.offNamed('/profile');
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
                            content: 'User Name must not be empty!',
                            contentColor: Colors.red,
                            bgColor: Colors.red.shade100,
                          );
                        }
                      },
                      imgUrl: kNameImg,
                    );
                  },
                  icon: Image.asset(
                    kEditImg,
                    color: Colors.white,
                    scale: 1,
                  )),
            )),
        Positioned(
          left: leftRightPadding,
          right: leftRightPadding,
          bottom: 110.0,
          child: ListTile(
            contentPadding: const EdgeInsets.all(0.0),
            title: Text(
              _email,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: kBodyWhiteTextStyle,
            ),
            trailing: IconButton(
                padding: const EdgeInsets.all(10.0),
                onPressed: () {
                  _editDialog(
                    title: 'Edit User Email',
                    controller: _emailController,
                    inputType: TextInputType.emailAddress,
                    onSave: () {
                      String _email = _emailController.text;
                      bool _isValid = Validators.validateUserName(_email);
                      if (_isValid) {
                        Utils.checkInternetConnection(context)
                            .then((isConnected) async {
                          if (isConnected) {
                            _userRepository.updateEmail(_id, _email);
                            SharedData.updateEmail(_email);
                            CustomSnackbar.buildSnackBar(
                              context: context,
                              content: 'Email Update Successful!',
                              contentColor: Colors.teal,
                              bgColor: Colors.teal.shade100,
                            );
                            Get.back();
                            Get.offNamed('/profile');
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
                          content: 'Email must not be empty!',
                          contentColor: Colors.red,
                          bgColor: Colors.red.shade100,
                        );
                      }
                    },
                    imgUrl: kEmailImg,
                  );
                },
                icon: Image.asset(
                  kEditImg,
                  color: Colors.white,
                  scale: 1,
                )),
          ),
        ),
        Positioned(
          left: leftRightPadding,
          right: leftRightPadding,
          bottom: 60.0,
          child: ListTile(
            contentPadding: const EdgeInsets.all(0.0),
            title: Text(
              'notee/$_id',
              style:
              kBodyWhiteTextStyle.copyWith(fontStyle: FontStyle.italic),
            ),
            trailing: IconButton(
                splashColor: kPrimaryColor,
                onPressed: () {
                  Clipboard.setData(ClipboardData(
                    text: 'notee/$_id',
                  )).then((_) => {
                    CustomSnackbar.buildSnackBar(
                        context: context,
                        content: "Successfully copied to clipboard!",
                        contentColor: kTextColor,
                        bgColor: Colors.teal.shade100),
                  });
                },
                icon: Image.asset(
                  kCopyImg,
                  color: Colors.white,
                  scale: 1,
                )),
          ),
        ),
      ],
    );
  }

  //Dialog for editing name and email
  _editDialog(
      {required String title,
      required String imgUrl,
      required TextEditingController controller,
      required TextInputType inputType,
      required Function onSave}) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: CustomTextFormField(
                imgUrl: imgUrl,
                inputType: inputType,
                hintText: title,
                controller: controller,
              ),
              actions: <Widget>[
                CustomElevatedIconButton(
                    label: 'Cancel',
                    iconData: Icons.close_rounded,
                    bgColor: Colors.red.shade500,
                    onPressed: () {
                      Get.back();
                    }),
                CustomElevatedIconButton(
                    label: 'Save',
                    iconData: Icons.done_rounded,
                    bgColor: kIconColor,
                    onPressed: () => onSave()),
              ],
            );
          },
        );
      },
    );
  }

  _reports() {
    return ListTile(
      onTap: () {
        Get.to(() => Reports());
      },
      tileColor: kIconColor,
      shape: kRoundedListTileBorder,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: Image.asset(kReportImg),
      ),
      title: const Text(
        'Notes & Todo Reports',
        style: kBodyWhiteTextStyle,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white,
      ),
    );
  }

  _changeThemeListTile() {
    return ListTile(
      onTap: () {
        changeTheme();
      },
      shape: kRoundedListTileBorder,
      leading: IconButton(
        onPressed: () {},
        iconSize: 35,
        icon: CircleAvatar(
          backgroundImage: AssetImage(
            'assets/icons/theme/$_selectedTheme.gif',
          ),
        ),
        tooltip: '$_selectedTheme theme',
      ),
      title: const Text(
        'Change Theme',
        style: kBodyWhiteTextStyle,
      ),
      tileColor: kIconColor,
      trailing: Switch(
        onChanged: (val) {
          changeTheme();
        },
        value: _isDarkTheme,
      ),
    );
  }

  _changePassword() {
    return ListTile(
      onTap: () {
        Get.to(() => ChangePassword());
      },
      tileColor: kIconColor,
      shape: kRoundedListTileBorder,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: Image.asset(kPwdImg),
      ),
      title: const Text(
        'Change Password',
        style: kBodyWhiteTextStyle,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white,
      ),
    );
  }

  onSync(int index) {
    setState(() {
      _selectedSyncIndex = index;
    });
  }

  _appVersion() {
    return ListTile(
      tileColor: kIconColor,
      shape: kRoundedListTileBorder,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Image.asset(
          kVersionImg,
          fit: BoxFit.cover,
        ),
      ),
      title: const Text(
        'App Version',
        style: kBodyWhiteTextStyle,
      ),
      trailing: Text(
        _version,
        style: kBodyWhiteTextStyle.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }

  // _syncData() {
  //   return ListTile(
  //     onTap: () {
  //       int _selectedIndex = _selectedSyncIndex;
  //       showDialog(
  //           context: context,
  //           barrierDismissible: false,
  //           builder: (BuildContext context) {
  //             return StatefulBuilder(builder: (context, setState) {
  //               return AlertDialog(
  //                 actions: [
  //                   IconButton(
  //                     onPressed: () {
  //                       Get.back();
  //                     },
  //                     icon: Image.asset(
  //                       kCancelImg,
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                   IconButton(
  //                     onPressed: () {
  //                       onSync(_selectedIndex);
  //                       Get.back();
  //                     },
  //                     icon: Image.asset(
  //                       kDoneImg,
  //                       fit: BoxFit.cover,
  //                     ),
  //                   ),
  //                 ],
  //                 title: const Text(
  //                   "Sync data in Every",
  //                   style: kTitleTextStyle,
  //                 ),
  //                 content: SizedBox(
  //                   width: 200.0,
  //                   height: 380.0,
  //                   child: ListView.separated(
  //                     shrinkWrap: true,
  //                     itemCount: kSyncTime.length,
  //                     itemBuilder: (context, index) {
  //                       return SizedBox(
  //                         height: 60.0,
  //                         width: double.infinity,
  //                         child: ListTile(
  //                           key: Key(index.toString()),
  //                           title: Text(
  //                             kSyncTime[index],
  //                             style: _selectedIndex == index
  //                                 ? kBodyWhiteTextStyle
  //                                 : kBodyTextStyle,
  //                           ),
  //                           trailing: Visibility(
  //                             visible: _selectedIndex == index,
  //                             child: const Icon(
  //                               Icons.done,
  //                               color: Colors.white,
  //                             ),
  //                           ),
  //                           selected: _selectedIndex == index,
  //                           onTap: () {
  //                             setState(() {
  //                               _selectedIndex = index;
  //                             });
  //                           },
  //                           selectedTileColor: kIconColor,
  //                         ),
  //                       );
  //                     },
  //                     separatorBuilder: (BuildContext context, int index) {
  //                       return const Divider(
  //                         height: 2.0,
  //                         color: kIconColor,
  //                       );
  //                     },
  //                   ),
  //                 ),
  //               );
  //             });
  //           });
  //     },
  //     tileColor: kIconColor,
  //     shape: kRoundedListTileBorder,
  //     leading: IconButton(
  //       onPressed: null,
  //       color: kIconColor,
  //       icon: Image.asset(
  //         kSyncImg,
  //         fit: BoxFit.cover,
  //       ),
  //     ),
  //     title: const Text(
  //       'Sync data',
  //       style: kBodyWhiteTextStyle,
  //     ),
  //     trailing: Text(
  //       kSyncTime[_selectedSyncIndex],
  //       style: const TextStyle(color: Colors.white, fontSize: 14.0),
  //     ),
  //   );
  // }

  _privacyPolicy() {
    return ListTile(
      onTap: () {
        Get.to(() => const PrivacyPolicy(), transition: Transition.fade);
      },
      shape: kRoundedListTileBorder,
      leading: IconButton(
        onPressed: () {},
        icon: Image.asset(
          kPolicyImg,
          fit: BoxFit.cover,
        ),
      ),
      title: const Text(
        'Privacy Policy',
        style: kBodyWhiteTextStyle,
      ),
      tileColor: kIconColor,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white,
      ),
    );
  }

  _aboutUs() {
    return ListTile(
      onTap: () {
        Get.to(const AboutMe());
      },
      tileColor: kIconColor,
      shape: kRoundedListTileBorder,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
        child: Image.asset(
          kInfoImg,
          fit: BoxFit.cover,
        ),
      ),
      title: const Text(
        'About Me',
        style: kBodyWhiteTextStyle,
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Colors.white,
      ),
    );
  }

  _deleteAccount() {
    return CustomElevatedButton(
      onPressed: () {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
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
                      Utils.checkInternetConnection(context)
                          .then((isConnected) {
                        if (isConnected) {
                          _userRepository.deleteUser(_id);
                          SharedData.deleteUserData();
                          CustomSnackbar.buildSnackBar(
                            context: context,
                            content: 'Account deleted successfully!',
                            contentColor: Colors.teal,
                            bgColor: Colors.teal.shade100,
                          );
                          SharedData.setLoggedIn(false);
                          Future.delayed(const Duration(milliseconds: 300), () {
                            Get.offNamedUntil('/home', (route) => false);
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
                    },
                    icon: Image.asset(
                      kDoneImg,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
                title: const Text(
                  "Delete this account?",
                  style: kTitleDangerTextStyle,
                ),
                content: Image.asset(
                  kCautionImg,
                  width: 150.0,
                  height: 150.0,
                ),
              );
            });
      },
      label: 'Delete Account',
      bgColor: kRedColor,
    );
  }
}
