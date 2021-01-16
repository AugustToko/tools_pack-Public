/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared/config/global_settings.dart';
import 'package:toolspack/pages/splash_page.dart';

import 'main_page.dart';

class PermissionPage extends StatefulWidget {
  static const routeName = "/GuidePage";

  final bool reView;

  PermissionPage({this.reView = false});

  @override
  State<StatefulWidget> createState() {
    return PermissionPageState();
  }

  static final status = [
    Permission.locationWhenInUse.status,
    Permission.storage.status,
    Permission.phone.status,
    Permission.camera.status,
  ];

  static Future<bool> checkPermission({bool isWeb = false}) async {
    if (isWeb) return true;
    if (Platform.isWindows) return true;
    final stream = Stream.fromIterable(status);
    await for (final s in stream) {
      if (!await s.isGranted) return false;
    }
    return true;
  }

  static Future<bool> request() async {
//      bool isShown = await Permission.contacts.shouldShowRequestRationale;
    // ----------------------- 申请权限
    Map<Permission, PermissionStatus> statuses = await [
      Permission.locationWhenInUse,
      Permission.storage,
      Permission.phone,
      Permission.camera,
      Permission.notification,
    ].request();

    if (Platform.isIOS) {
      statuses = await [
//        Permission.locationWhenInUse,
        Permission.storage,
        Permission.notification,
        Permission.camera,
      ].request();
    }

    final stream = Stream.fromIterable(statuses.values);

    await for (final v in stream) {
      if (!v.isGranted) {
        debugPrint('=========== PERMISSION ERROR =============');
        debugPrint(statuses.keys.toList()[v.index].toString());
        showMyToast('请授予完整权限!');
        return false;
//        exitApp();
      }
    }
    if (Platform.isAndroid) {
      final bool result =
          await GlobalSettings.channel.invokeMethod('canInstall'); // 2

      if (!result) {
        showMyToast('请允许安装未知来源应用程序！');
        await GlobalSettings.channel
            .invokeMethod('requestInstallPermission'); // 2
      }
    }
    return true;
  }
}

class PermissionPageState extends State<PermissionPage> {
  bool granted = false;
  String btnText = "同意并授予全部权限";

  final TextStyle styleContentText = TextStyle(fontSize: 16, fontFamily: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(60),
          child: Center(
            child: Column(
              children: <Widget>[
                SplashPage.newLogo(context),
                SizedBox(
                  height: 20,
                ),
                Divider(),
                SizedBox(
                  height: 20,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "APP 权限说明",
                      style: TextStyle(fontSize: 25),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "1. 设备唯一性:",
                      style: styleContentText,
                    ),
                    Text(
                      "本程序将收集您的设备信息以确保唯一性。",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "2. 获取当前位置信息:",
                      style: styleContentText,
                    ),
                    Text(
                      "本程序将收集您的设备的位置信息以确保核心功能正常工作，并优化 APP 内部功能。",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "3. 设备存储:",
                      style: styleContentText,
                    ),
                    Text(
                      "本程序将在您的设备上存储数据以确保核心功能正常工作。",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "4. 互联网:",
                      style: styleContentText,
                    ),
                    Text(
                      "本程序将使用您的设备继续联网操作以确保功能正常工作。且在您使用过程中会发送匿名数据到服务器，以优化用户体验。",
                      style: TextStyle(fontSize: 15),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      "5. 安装未知来源应用程序:",
                      style: styleContentText,
                    ),
                    Text(
                      "请允许本 APP 安装未知来源的应用程序，以确保更新功能正常。",
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "6. 加入电源管理白名单:",
                      style: styleContentText,
                    ),
                    const Text(
                      "请允许本 APP 加入电源管理白名单，以确保实时推送正常运作。",
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "6. 摄像机访问权限:",
                      style: styleContentText,
                    ),
                    Text(
                      "请允许本 APP 拍照，以确保二维码识别功能正常运作。",
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        FlatButton(
                          onPressed: granted
                              ? null
                              : () {
                                  PermissionPage.request().then((result) {
                                    print("permission: $result");
                                    setState(() {
                                      btnText = result ? "已授权" : "授权失败，点击重试";
                                      granted = result;
                                    });
                                  });
                                },
                          child: Text(btnText),
                          textColor: Colors.blueAccent,
                        ),
                        FlatButton(
                          onPressed: !granted
                              ? null
                              : () {
                                  if (widget.reView) {
                                    Navigator.pop(context);
                                  } else {
                                    Navigator.pushAndRemoveUntil(context,
                                        MaterialPageRoute(builder: (ctx) {
                                      return MainPage();
                                    }), (r) => r == null);
                                  }
                                },
                          child: const Text("下一步"),
                          textColor: Colors.blueAccent,
                        )
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
