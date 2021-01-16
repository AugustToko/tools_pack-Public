/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:provider/provider.dart';
import 'package:toolspack/main.dart';
import 'package:toolspack/utils/shared_prefs.dart';
import 'package:toolspack/utils/ui_tools.dart';
import 'package:toolspack_shared/model/pack_data.dart';
import 'package:toolspack_shared/model/student_info.dart';
import 'package:toolspacklibs/model/login_cache.dart';
import 'package:toolspacklibs/utils/net_utils.dart';

import '../toolspack_theme.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final FocusNode myFocusNodeSchoolLogin = FocusNode();
  final FocusNode myFocusNodeSpcodeLogin = FocusNode();
  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  TextEditingController loginSchoolController = TextEditingController();
  TextEditingController loginSpcodeController = TextEditingController();
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  bool _obscureTextLogin = true;

  PageController _pageController;

  /// 当前平台
  PlatformType currentPlatform;

  // 是否全部平台已经登录
  bool allLogined;

  @override
  void initState() {
    super.initState();

    final loginCacheModel =
        Provider.of<LoginCacheModel>(context, listen: false);

    //------------------------- 预加载账号信息 -------------------------
    if (loginCacheModel.spcode != null &&
        loginCacheModel.spcode.trim().isNotEmpty) {
      loginSpcodeController.text = loginCacheModel.spcode;
    }

    SharedPreferenceUtil.getString(SP_PASSWORD).then((str) {
      if (str != null && str.trim().isNotEmpty) {
        loginPasswordController.text = str;
      }
    });

    SharedPreferenceUtil.getString(SP_ACCOUNT).then((str) {
      if (str != null && str.trim().isNotEmpty) {
        loginEmailController.text = str;
      }
    });

    SharedPreferenceUtil.getString(SP_SCHOOL).then((str) {
      if (str != null && str.trim().isNotEmpty) {
        loginSchoolController.text = str;
      }
    });
    //------------------------- 预加载账号信息 -------------------------

    if (loginCacheModel.currentStudentInfo == null) {
      currentPlatform = loginCacheModel.packData.platforms[0];
    } else {
      // 循环找出没有登录过的平台
      loginCacheModel.packData.platforms.forEach((p) {
        if (!loginCacheModel.isPlatformLogined(p)) {
          currentPlatform = p;
        }
      });

      if (currentPlatform == null) allLogined = true;
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        unfocusAll();
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return null;
          },
          child: Stack(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        ToolsPackAppTheme.loginGradientStart,
                        ToolsPackAppTheme.loginGradientEnd
                      ],
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: SizedBox(
                  height: double.infinity,
                ),
              ),
              SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      AppBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/images/logo.png',
                              height: 70,
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Text(
                              '多平台统一登录',
                              style:
                                  TextStyle(fontSize: 35, color: Colors.white),
                            )
                          ],
                        ),
                      ),
//                Padding(
//                  padding: EdgeInsets.only(top: 20.0),
//                  child: _buildMenuBar(context),
//                ),
                      _buildSignIn(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController?.dispose();

    myFocusNodeSchoolLogin.dispose();
    myFocusNodeEmailLogin.dispose();
    myFocusNodePasswordLogin.dispose();

    loginEmailController.dispose();
    loginPasswordController.dispose();
    loginSchoolController.dispose();

    loginSpcodeController.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    FocusScope.of(context).requestFocus(FocusNode());
    _scaffoldKey.currentState?.removeCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(
        value,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16.0,
        ),
      ),
      backgroundColor: Colors.blue,
      duration: Duration(seconds: 3),
    ));
  }

//  Widget _buildMenuBar(BuildContext context) {
//    return Container(
//      width: 300.0,
//      height: 50.0,
//      decoration: BoxDecoration(
//        color: Color(0x552B2B2B),
//        borderRadius: BorderRadius.all(Radius.circular(25.0)),
//      ),
//      child: CustomPaint(
//        painter: TabIndicationPainter(pageController: _pageController),
//        child: Row(
//          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//          children: <Widget>[],
//        ),
//      ),
//    );
//  }

  void unfocusAll() {
    myFocusNodeSchoolLogin.unfocus();
    myFocusNodeEmailLogin.unfocus();
    myFocusNodePasswordLogin.unfocus();
  }

  Widget _buildSignIn(BuildContext context) {
    final loginCacheModel =
        Provider.of<LoginCacheModel>(context, listen: false);

    var platformLoginedText = '';
    loginCacheModel.studentLoginList.forEach((p) {
      platformLoginedText += (p.obj.account + '@' + p.platformType.name + '\n');
    });

    if (platformLoginedText.trim() == '') platformLoginedText = '无';

    var loginedText = Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: FlatButton(
          onPressed: null,
          child: Text(
            "已登录的平台:\n$platformLoginedText",
            style: TextStyle(
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          )),
    );

    return Container(
      padding: EdgeInsets.only(top: 23.0),
      child: Column(
        children: <Widget>[
          Stack(
            alignment: Alignment.topCenter,
            overflow: Overflow.visible,
            children: <Widget>[
              Card(
                elevation: 2.0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  width: 300.0,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeSchoolLogin,
                          controller: loginSchoolController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.school,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: "学校",
                            hintStyle: TextStyle(fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeEmailLogin,
                          controller: loginEmailController,
                          keyboardType: TextInputType.text,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.user,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: "账号",
                            hintStyle: TextStyle(fontSize: 17.0),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodePasswordLogin,
                          controller: loginPasswordController,
                          obscureText: _obscureTextLogin,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.lock,
                              size: 22.0,
                              color: Colors.black,
                            ),
                            hintText: "密码",
                            hintStyle: TextStyle(fontSize: 17.0),
                            suffixIcon: GestureDetector(
                              onTap: _toggleLogin,
                              child: Icon(
                                _obscureTextLogin
                                    ? FontAwesomeIcons.eye
                                    : FontAwesomeIcons.eyeSlash,
                                size: 15.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 250.0,
                        height: 1.0,
                        color: Colors.grey[400],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: 15.0, bottom: 15.0, left: 25.0, right: 25.0),
                        child: TextField(
                          focusNode: myFocusNodeSpcodeLogin,
                          controller: loginSpcodeController,
                          keyboardType: TextInputType.visiblePassword,
                          style: TextStyle(fontSize: 16.0, color: Colors.black),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            icon: Icon(
                              FontAwesomeIcons.code,
                              color: Colors.black,
                              size: 22.0,
                            ),
                            hintText: "特征码",
                            hintStyle: TextStyle(fontSize: 17.0),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 320.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: ToolsPackAppTheme.loginGradientStart,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                    BoxShadow(
                      color: ToolsPackAppTheme.loginGradientEnd,
                      offset: Offset(1.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  gradient: LinearGradient(
                      colors: [
                        ToolsPackAppTheme.loginGradientEnd,
                        ToolsPackAppTheme.loginGradientStart
                      ],
                      begin: const FractionalOffset(0.2, 0.2),
                      end: const FractionalOffset(1.0, 1.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: MaterialButton(
                    highlightColor: Colors.transparent,
                    splashColor: ToolsPackAppTheme.loginGradientEnd,
                    //shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 42.0),
                      child: Text(
                        "登录",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      unfocusAll();

                      if (kReleaseMode) {
                        if (loginSchoolController.text.isEmpty ||
                            loginEmailController.text.isEmpty ||
                            loginPasswordController.text.isEmpty ||
                            loginSpcodeController.text.isEmpty) {
                          showErrorToast(context, '请输入完整信息!');
                          return;
                        }
                      } else {
                        loginSpcodeController.text = 'HYITshuake';
                      }

                      DialogUtil.showBlurDialog(context, (ctx) {
                        return LoadingDialog(text: '登录中...');
                      }, barrierDismissible: false);

                      StudentInfoUnit info;

                      if (kReleaseMode) {
                        info = await NetUtils4Wk.getStudentInfo(
                            loginSchoolController.text,
                            loginEmailController.text,
                            loginPasswordController.text,
                            currentPlatform);
                      } else {
                        info = null;
                      }

                      // 取消弹出加载对话框
                      Navigator.pop(context);

                      if (info != null && info.success && info.obj.status) {
                        final loginCache = Provider.of<LoginCacheModel>(context,
                            listen: false);

                        // 设置特征码
                        final spcodeInput = loginSpcodeController.text;

                        // 更新 pack data
                        final packData = await NetUtils4Wk.getToolsPackData(
                            spcode: spcodeInput);

                        // 校验特征码
                        if (packData == null ||
                            packData.agentModel == null ||
                            packData.agentModel.priceP1 == -1) {
                          showErrorToast(context, '特征码错误');
                        } else {
                          loginCache.currentStudentInfo = info;

                          loginCacheModel.spcode = spcodeInput;
                          loginCacheModel.packData = packData;

                          await SharedPreferenceUtil.setString(
                              SP_SPCODE, spcodeInput);
                          await SharedPreferenceUtil.setString(
                              SP_SCHOOL, loginSchoolController.text);
                          await SharedPreferenceUtil.setString(
                              SP_ACCOUNT, loginEmailController.text);
                          await SharedPreferenceUtil.setString(
                              SP_PASSWORD, loginPasswordController.text);

                          Navigator.pop(context, loginCache.currentStudentInfo);
                          showSuccessToast(context, '登录成功');
                        }
                      } else {
                        showErrorToast(context, '失败，检查您的平台账号密码是否正确。');
                      }
                    }),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: MaterialButton(
                shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Colors.white),
                    borderRadius: BorderRadius.all(Radius.circular(6))),
                onPressed: () {
                  DialogUtil.showBlurDialog<PlatformType>(context, (ctx) {
                    return SimpleDialog(
                      title: Text('选择平台'),
                      children: List<Widget>.generate(
                          loginCacheModel.packData.platforms.length, (index) {
                        final platform =
                            loginCacheModel.packData.platforms[index];

                        // TODO: 是否支持同平台不同账号同时登录
                        // 检测是否已经登录过
                        var logined =
                            loginCacheModel.isPlatformLogined(platform);

                        return Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(platform.name),
                              trailing: logined
                                  ? Text('已登录')
                                  : Icon(Icons.arrow_right),
                              onTap: () {
                                if (!logined) {
                                  Navigator.pop(context, platform);
                                } else {
                                  showErrorToast(context, '该平台已登录');
                                }
                              },
                            ),
                            Divider(),
                          ],
                        );
                      }),
                    );
                  }).then((val) {
                    if (val != null) {
                      setState(() {
                        currentPlatform = val;
                      });
                    }
                  });
                },
                child: Text(
                  "当前平台：${currentPlatform.name}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                )),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
            child: FlatButton(
                onPressed: () {
                  UiTools.showLoginHelpDialog(context);
                },
                child: Text(
                  "帮助?",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                )),
          ),
          loginedText,
          SizedBox(
            height: 30,
          )
//          Padding(
//            padding: EdgeInsets.only(top: 10.0),
//            child: Row(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Container(
//                  decoration: BoxDecoration(
//                    gradient: LinearGradient(
//                        colors: [
//                          Colors.white10,
//                          Colors.white,
//                        ],
//                        begin: const FractionalOffset(0.0, 0.0),
//                        end: const FractionalOffset(1.0, 1.0),
//                        stops: [0.0, 1.0],
//                        tileMode: TileMode.clamp),
//                  ),
//                  width: 100.0,
//                  height: 1.0,
//                ),
//                Padding(
//                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                  child: Text(
//                    "Or",
//                    style: TextStyle(
//                        color: Colors.white,
//                        fontSize: 16.0,
//                        fontFamily: "WorkSansMedium"),
//                  ),
//                ),
//                Container(
//                  decoration: BoxDecoration(
//                    gradient: LinearGradient(
//                        colors: [
//                          Colors.white,
//                          Colors.white10,
//                        ],
//                        begin: const FractionalOffset(0.0, 0.0),
//                        end: const FractionalOffset(1.0, 1.0),
//                        stops: [0.0, 1.0],
//                        tileMode: TileMode.clamp),
//                  ),
//                  width: 100.0,
//                  height: 1.0,
//                ),
//              ],
//            ),
//          ),
//          Row(
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              Padding(
//                padding: EdgeInsets.only(top: 10.0, right: 40.0),
//                child: GestureDetector(
//                  onTap: () => showInSnackBar("Facebook button pressed"),
//                  child: Container(
//                    padding: const EdgeInsets.all(15.0),
//                    decoration: BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: Colors.white,
//                    ),
//                    child: Icon(
//                      FontAwesomeIcons.facebookF,
//                      color: Color(0xFF0084ff),
//                    ),
//                  ),
//                ),
//              ),
//              Padding(
//                padding: EdgeInsets.only(top: 10.0),
//                child: GestureDetector(
//                  onTap: () => showInSnackBar("Google button pressed"),
//                  child: Container(
//                    padding: const EdgeInsets.all(15.0),
//                    decoration: BoxDecoration(
//                      shape: BoxShape.circle,
//                      color: Colors.white,
//                    ),
//                    child: Icon(
//                      FontAwesomeIcons.google,
//                      color: Color(0xFF0084ff),
//                    ),
//                  ),
//                ),
//              ),
//            ],
//          ),
        ],
      ),
    );
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

//  void _toggleSignup() {
//    setState(() {
//      _obscureTextSignup = !_obscureTextSignup;
//    });
//  }
//
//  void _toggleSignupConfirm() {
//    setState(() {
//      _obscureTextSignupConfirm = !_obscureTextSignupConfirm;
//    });
//  }
}
