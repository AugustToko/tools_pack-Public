/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:toolspack/main.dart';

class AboutPageWk extends StatefulWidget {
  static const routeName = "/AboutPage";

  AboutPageWk({Key key}) : super(key: key);

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPageWk> {
  final digits = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            children: <Widget>[
              AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                    color: Theme.of(context).textTheme.bodyText1.color),
              ),
              SizedBox(
                height: 20,
              ),
              Image.asset(
                "assets/images/logo.png",
                height: 100,
              ),
              SizedBox(
                height: 10,
              ),
              InkWell(
                customBorder: CircleBorder(),
                child: Column(
                  children: <Widget>[
                    Text(
                      appName,
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '专业的课程解决方案',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                onTap: () {
                  showMyToast('>_<!!');
                },
              ),
            ],
          ),
          Column(
            children: <Widget>[
              CupertinoButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text('$appName 邀您合作'),
                          content: Text('加入 $appName 来赚取属于你的第一桶金！'),
                          actions: <Widget>[
                            FlatButton(
                                onPressed: true
                                    ? null
                                    : () {
                                        showMyToast('暂未开放');
                                      },
                                child: Text('查看资格'))
                          ],
                        );
                      });
                },
                pressedOpacity: 0.8,
                child: Container(
                  alignment: Alignment.center,
                  width: 300,
                  height: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(30.0)),
                      gradient: LinearGradient(colors: [
                        Color(0xFF686CF2),
                        Color(0xFF0E5CFF),
                      ]),
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x4D5E56FF),
                            offset: Offset(0.0, 4.0),
                            blurRadius: 13.0)
                      ]),
                  child: Text(
                    "加入我们",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              RaisedButton(
                shape: StadiumBorder(),
                child: Text(
                  "开源许可证",
                  style:
                      TextStyle(color: Theme.of(context).textTheme.title.color),
                ),
                elevation: 0,
                onPressed: () {
                  DialogUtil.showBlurDialog(context, (ctx) {
                    return AboutDialog(
                      applicationIcon: Image.asset(
                        "assets/images/logo.png",
                        height: 50,
                      ),
                      applicationName: appName,
                      applicationVersion: 'version: $versionNum',
                      applicationLegalese: 'Developed by TP Project, @LTS_TP',
                    );
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Developed by TP Project, @LTS_TP',
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
