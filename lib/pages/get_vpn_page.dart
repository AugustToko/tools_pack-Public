/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/drink_card/drink_card.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class GetVPNPage extends StatefulWidget {
  @override
  _GetVPNPagePageState createState() => _GetVPNPagePageState();
}

class SSRModel {
  String ipAddress;
  String port;
  String pass;
  String method;
  @Deprecated('URL 失效')
  String qrUrl;

  String v2rayUrl;

  SSRModel(
      {this.ipAddress,
      this.port,
      this.pass,
      this.method,
      this.qrUrl,
      this.v2rayUrl});
}

class _GetVPNPagePageState extends State<GetVPNPage> {
  final vpnUrls = <String>[];

  Future<List<SSRModel>> getSSRA() async {
    final resultData = <SSRModel>[];

    try {
      final urlRes = await Dio().get('URL_HERE');
      final List<dynamic> urlData =
          ((json.decode(urlRes.toString()) as Map<String, dynamic>)['urls']);

      if (urlData.isEmpty) {
        Navigator.pop(context);
        showMyToast('正在维护...');
      }

      await for (final element in Stream.fromIterable(urlData)) {
        vpnUrls.add(element as String);
      }

      final bodyText = await Dio().get(vpnUrls[0]);

      if (bodyText != null) {
        dom.Document documentUsefulApps = parser.parse(bodyText.toString());
        documentUsefulApps
            .getElementsByClassName('hover-text')
            .forEach((element) {
          final c = element.children;
          if (c.length == 3) {
            resultData.add(SSRModel(
                v2rayUrl: c[0].children[0].attributes['data-clipboard-text']));
          } else {
            final ipData = c[0].children[0].text;
            final portData = c[1].children[0].text;
            final passData = c[2].children[0].text;
            final methodData = c[3].text;
            final qrData = c[4].children[0].attributes['href'];
            resultData.add(SSRModel(
                ipAddress: ipData,
                port: portData,
                pass: passData,
                method: methodData,
                qrUrl: qrData));
          }
        });
      }
    } catch (e, s) {
      printDebugMes(e.toString());
      printDebugMes(s.toString());
    }

    return resultData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.topLeft,
        children: <Widget>[
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 100, bottom: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 16,
                  ),
                  DrinkListCard(
                    height: 200,
                    bgColor: Theme.of(context).backgroundColor,
                    leading: CircleAvatar(
                      child: Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                      radius: 20,
                    ),
                    title: Text(
                      '公告',
                      style: Styles.text(18, true),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.white,
                    ),
                    contentTitle: '每6小时刷新一次，如果失效请使用新链接。',
                    contentBody: '本页内容均收集自互联网。',
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 16, right: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: Stack(
                            children: <Widget>[
                              Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlueAccent,
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(30.0),
                                  ),
//                              boxShadow: <BoxShadow>[
//                                BoxShadow(
//                                    color: Colors.blue,
//                                    offset: const Offset(1.1, 1.1),
//                                    blurRadius: 10.0),
//                              ],
                                ),
                                child: Center(
                                  child: Text(
                                    '查看教程',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18,
                                      letterSpacing: 0.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(30.0),
                                    ),
                                    child: Container(),
                                    onTap: () {
                                      launch(
                                          'https://docs.zxnet.org/#/android');
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  buildBodyTile(),
                ],
              ),
            ),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                    color: Theme.of(context)
                        .scaffoldBackgroundColor
                        .withOpacity(0.8)),
              ),
            ),
          ),
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 45, right: 16, left: 16),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '$appName',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            '科学上网',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 0.27,
                            ),
                          ),
                        ],
                      ),
                    ),
//                    FlatButton(
//                      onPressed: () {
//                        DialogUtil.showBlurDialog(context, (ctx) {
//                          return AlertDialog(
//                            title: Text('我的信息'),
//                            content: Text('FFF'),
//                            actions: <Widget>[
//                              FlatButton(
//                                  onPressed: () {
//                                    Navigator.pop(context);
//                                  },
//                                  child: Text('关闭')),
//                              FlatButton(
//                                  onPressed: () {},
//                                  child: Text(
//                                    'Other',
//                                    style: TextStyle(color: Colors.redAccent),
//                                  ))
//                            ],
//                          );
//                        });
//                      },
//                      child: Text(
//                        'Button',
//                        style: TextStyle(
//                          fontWeight: FontWeight.bold,
//                          fontSize: 15,
//                          letterSpacing: 0.27,
//                          color: DesignCourseAppTheme.nearlyBlue,
//                        ),
//                      ),
//                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  buildBodyTile() {
    return FutureBuilder<List<SSRModel>>(
      builder: (ctx, data) {
        if (data.hasData && data.data != null) {
          return ExpansionTile(
            title: Text('第一梯队'),
            leading: CircleAvatar(
              child: Text(
                '1',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.pinkAccent,
            ),
            subtitle: Text(vpnUrls[0]),
            children: List<Widget>.generate(data.data.length, (index) {
              final ssrData = data.data[index];

              if (ssrData.v2rayUrl != null) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('V'),
                  ),
                  title: const Text('V2RAY URL'),
                  subtitle: Text(
                    '${ssrData.v2rayUrl.replaceAll('\n', '').replaceAll('\r', '')}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: ssrData.v2rayUrl));
                    showMyToast('已复制');
                  },
                );
              } else {
                final adrText = Text('地址: ' + ssrData.ipAddress);

                return ListTile(
                  leading: CircleAvatar(
                    child: Text('S'),
                  ),
                  title: adrText,
                  subtitle: Text(
                      '端口: ${ssrData.port}密码: ${ssrData.pass}加密: ${ssrData.method}'),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (context) {
                      return AlertDialog(
                        title: Text('详情（点击单个项目进行复制）'),
                        content: Wrap(
                          direction: Axis.vertical,
                          children: <Widget>[
                            InkWell(
                              child: adrText,
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: ssrData.ipAddress));
                                showMyToast('已复制');
                              },
                            ),
                            InkWell(
                              child: Text(
                                  '端口: ${ssrData.port.replaceAll('\n', '')}'),
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: ssrData.port));
                                showMyToast('已复制');
                              },
                            ),
                            InkWell(
                              child: Text(
                                  '密码: ${ssrData.pass.replaceAll('\n', '')}'),
                              onTap: () {
                                Clipboard.setData(
                                    ClipboardData(text: ssrData.pass));
                                showMyToast('已复制');
                              },
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          DialogUtil.getDialogCloseButton(context)
                        ],
                      );
                    });
                  },
                );
              }
            }),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Center(
              child: Column(
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text('正在加载...')
                ],
              ),
            ),
          );
        }
      },
      future: getSSRA(),
    );
  }
}
