/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:shared/config/global_settings.dart';
import 'package:toolspack/pages/splash_page.dart';
import 'package:toolspack/utils/shared_prefs.dart';
import 'package:toolspacklibs/model/login_cache.dart';

import 'pages/login_page.dart';

const versionNum = 28;
const versionName = '0.0.6';

const appName = '课程助手';

const String pkg = "com.toolshouse.toolspack/tp";

@Deprecated('集成于 taobaoke_shared')
String OAID = '';

/// 模糊统一值
const blurSigma = 20.0;

/// For [SharedPreferenceUtil]
const String SP_SPCODE = 'SP_CODE';
const String SP_SCHOOL = 'SP_SCHOOL';
const String SP_ACCOUNT = 'SP_ACCOUNT';
const String SP_PASSWORD = 'SP_PASSWORD';

/// 历史订单
const String SP_SAVEORDERS = 'SP_SAVEORDERS';

/// APP 版本
const String SP_VERSION = 'SP_VERSION';

/// 用于登陆代理页面的代理账号
const String SP_AGENTACC = 'SP_AGENTACC';

/// 用于登陆代理页面的代理密码
const String SP_AGENTPASS = 'SP_AGENTPASS';

final loginCache = LoginCacheModel();

Future<void> main() async {
  GlobalSettings.appName = appName;

  if (!kIsWeb)
    GlobalSettings.channel = const MethodChannel('com.toolshouse.toolspack/tp');

  runApp(Provider<LoginCacheModel>.value(
    value: null,
    child: ChangeNotifierProvider<LoginCacheModel>.value(
      value: loginCache,
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: ADMOB
//    FirebaseAdMob.instance
//        .initialize(appId: 'ca-app-pub-5884805917427671~7002914827');
    return OKToast(
      child: MaterialApp(
        title: appName,
        themeMode: ThemeMode.system,
        darkTheme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: Colors.black,
          textTheme: TextTheme(
            bodyText1: TextStyle(
              color: Colors.white,
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
            headline6: TextStyle(
              color: Colors.white,
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
            subtitle1: TextStyle(
              color: Colors.white,
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
            bodyText2: TextStyle(
              color: Colors.white,
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
          ),
        ),
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
          backgroundColor: Colors.white,
          textTheme: TextTheme(
            bodyText1: TextStyle(
              color: Colors.black,
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
            subtitle1: TextStyle(
              color: Colors.black,
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
            subtitle2: TextStyle(
              color: Colors.black,
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
            headline6: TextStyle(
              color: Colors.black,
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
            bodyText2: TextStyle(
              color: Colors.black.withOpacity(1),
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
            headline5: TextStyle(
              color: Colors.black.withOpacity(1),
//                fontFamily: 'GenJyuuGothic-Regular（源柔ゴシック）'
            ),
          ),
        ),
        home: SplashPage(),
      ),
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}

/// Toast
/// [Deprecated('use showMyToast')]
@Deprecated('use showMyToast')
showWkToast(final String content) async {
  showMyToast(content);
}

gotoLoginPage(ctx) {
  return Navigator.of(ctx).push(MaterialPageRoute(
    builder: (ctx) {
      return LoginPage();
    },
  ));
}

@Deprecated('use printDebugMes')
printDebug4Wk(object) {
  printDebugMes(object);
}
