/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lingyun_flutter_net_shared/lingyun_flutter_net_shared.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:package_info/package_info.dart';
import 'package:shared/config/global_settings.dart';
import 'package:toolspack/main.dart';
import 'package:toolspack/pages/permission_page.dart';
import 'package:toolspack/utils/goto_pages.dart';
import 'package:toolspack/utils/shared_prefs.dart';
import 'package:toolspack/utils/shared_prefs_key.dart';
import 'package:toolspack/utils/ui_tools.dart';
import 'package:toolspacklibs/model/history_order.dart';
import 'package:toolspacklibs/utils/device_utils.dart';
import 'package:toolspacklibs/utils/net_utils.dart';

import 'intor_page.dart';
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SplashPageState createState() => _SplashPageState();

  static Widget newLogo(final BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(
            top: 0,
            left: 20,
            right: 20,
          ),
          child: Image.asset("assets/images/logo.png", height: 100),
        ),
        SizedBox(
          height: 20,
        ),
        Text("专业的网络学习解决方案"),
      ],
    );
  }
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    WidgetsBinding widgetsBinding = WidgetsBinding.instance;
    widgetsBinding.addPostFrameCallback((callback) async {
      await loginCache.init();
//      print(
//          'RemoteServerStatus: \nisEmpty:${await remoteServer.isEmpty}'
//          '\n${await remoteServer.single}');
//      remoteServer.addError((err) {
//        print('RemoteServerErrMsg: $err');
//      });

      // ----------------------- 处理历史订单
      SharedPreferenceUtil.getStringList(SP_SAVEORDERS).then((data) {
        if (data != null) {
          data.forEach((str) {
            var list = str.split('&&');
            if (list.length == 3) {
              loginCache.recentOrdersHistory
                  .add(HistoryOrder(list[0], list[1], list[2]));
              print('======= 历史订单加载完成 ======');
            }
          });
        }
      });

      // ----------------------- 获取远端数据
      final packData =
          await NetUtils4Wk.getToolsPackData(spcode: loginCache.spcode);
      if (packData == null) {
        showMyToast('获取数据失败！');
        print('======== PACKDATA 获取失败 ======');
        await showErrorDialog('服务器正在维护',
            contentText: '从远程服务器获取数据失败!\n请稍后再试。\n注意：服务器状态并不会影响到您的订单进度。');
      }
      loginCache.packData = packData;

      print('======== PACKDATA 获取完成 ======');

      // ----------------------- 检查错误信息
      if (kReleaseMode) {
        if (packData.notice.startsWith('Error:')) {
          showMyToast('错误！');
          await showErrorDialog('错误',
              contentText: '${packData.notice}\n注意：服务器状态并不会影响到订单。');
        }
      }

      // ----------------------- 获取特征码
      final checkSpcode = await SharedPreferenceUtil.getString('SP_CODE');
      loginCache.spcode = checkSpcode;
      print('======= 特征码获取完成 $checkSpcode ======');

      // ----------------------- 检查 APP 更新
      if (kReleaseMode && !kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // only support ios android
        final packageInfo = await PackageInfo.fromPlatform();
        print('=============== VERSION CHECK ===============');
        print(packageInfo.buildNumber);
        print(packageInfo.version);

        try {
          // TODO: 当使用 --split-per-abi build 时，v8 versionCode 偏移 2000
          // TODO: 当使用 --split-per-abi build 时，v7 versionCode 偏移 1000
//          final iVer = int.parse(packageInfo.buildNumber) - 2000;
          if (packData.versionCode > versionNum) {
            await UiTools.showUpdateDialog(context);
          } else if (packData.versionCode < versionNum) {
            showMyToast(
                'APP 出现错误 curr_v: $versionNum, r_v: ${packData.versionCode}！');
            await showErrorDialog('APP 出现错误', contentText: '请检查你的 APP 版本!');
          } else {
            print('版本检测通过 versionCode: $versionNum');
            final spVersion = await SharedPreferenceUtil.getInt(SP_VERSION);
            if (spVersion == null || spVersion != versionNum) {
              await UiTools.showChangelogDialog(context);
              await SharedPreferenceUtil.setInt(SP_VERSION, versionNum);
            }
          }
        } catch (e, s) {
          print(e.toString());
          print(s.toString());
        }
        print('======== APP 更新检查完成 ======');
      }

      if (!kIsWeb && Platform.isAndroid) {
        // getOAID
        final String result =
            await GlobalSettings.channel.invokeMethod('getOAID'); // 2

        if (result.trim().isEmpty) {
          print('OAID IS NULL');
        } else {
          OAID = result;
          print('My OAID: $OAID');
        }
        print('======== OAID DONE ======');

        await DeviceAndroidUtils4Wk.init();
        print('======== ANDROID DEVICE INFO CHECKED! ======');
      }

      final tempHitokoto = await LingYunNetTools.getHitokoto();
      if (tempHitokoto != null) {
        loginCache.hitokoto = tempHitokoto.hitokoto;
      }
      print('======== 一言检查完成 ======');

      // ----------------------- 是否第一次进入APP
      bool checkFirst = (await SharedPreferenceUtil.getBool(
              SharedPrefsKeys.IS_FIRST_ENTER_APP)) ??
          true;
      print('======== CHECK FIRST DONE ======');

      if (checkFirst) {
        print('======== 前往 IntroScreen ======');
        Navigator.push(context, MaterialPageRoute(builder: (ctx) {
          return IntroScreen();
        }));
      } else {
        if (!kIsWeb) {
          final result = await PermissionPage.checkPermission();
          var targetPage = result ? MainPage() : PermissionPage();
          Navigator.push(context, MaterialPageRoute(builder: (ctx) {
            return (Platform.isAndroid || Platform.isIOS)
                ? targetPage
                : MainPage();
          }));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (ctx) {
            return MainPage();
          }));
        }
      }
    });

    super.initState();
  }

  /// 展示错误对话框
  Future<void> showErrorDialog(final String title,
      {final String contentText}) async {
    await DialogUtil.showBlurDialog(context, (ctx) {
      return AlertDialog(
        title: Text(title),
        content: contentText == null ? null : Text(contentText),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                exitApp(() {
                  if (loginCache.remoteSocket != null) {
                    loginCache.remoteSocket.close();
                  }
                });
              },
              child: Text('退出'))
        ],
      );
    }, barrierDismissible: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 10, left: 10, top: 10),
              child: SplashPage.newLogo(context),
            ),
            SizedBox(
              height: 150,
            )
          ],
        ),
      ),
    );
  }
}
