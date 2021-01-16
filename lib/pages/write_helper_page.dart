/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/html_parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:toolspacklibs/utils/net_utils.dart';

import '../main.dart';

class WriteHelperPage extends StatefulWidget {
  @override
  _WriteHelperPageState createState() => _WriteHelperPageState();
}

class _WriteHelperPageState extends State<WriteHelperPage> {
  final textController = TextEditingController();

  final FocusNode blankFocusNode = FocusNode();

  var textResult = 'Empty';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.topLeft,
          children: <Widget>[
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    EdgeInsets.only(left: 8, right: 8, top: 100, bottom: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(hintText: '文章，580字限制。'),
                        maxLines: 10,
                      ),
                    ),
                    Divider(),
                    Row(
                      children: <Widget>[
                        MaterialButton(
                          child: Text('同义词转换'),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            if (textController.text.isEmpty) {
                              showMyToast('文章为空');
                              return;
                            }

                            DialogUtil.showBlurDialog(
                                context,
                                (context) => LoadingDialog(
                                      text: '正在加载...',
                                      cancelable: true,
                                    ));

                            final data =
                                await NetUtils4Wk.getSynonymConversionData(
                                    textController.text);

                            Navigator.pop(context);

                            if (data == null) {
                              showErrorToast(context, '获取失败，请检查字数。');
                            } else {
                              setState(() {
                                textResult = data;
                              });
                            }
                          },
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        MaterialButton(
                          child: Text('AI自动重写'),
                          color: Theme.of(context).accentColor,
                          onPressed: () async {
                            if (textController.text.isEmpty) {
                              showMyToast('文章为空');
                              return;
                            }

                            DialogUtil.showBlurDialog(
                                context,
                                (context) => LoadingDialog(
                                      text: '正在加载...',
                                      cancelable: true,
                                    ));

                            final data = await NetUtils4Wk.getAIArticleData(
                                textController.text);

                            Navigator.pop(context);

                            if (data == null) {
                              showErrorToast(context, '获取失败，请检查字数。');
                            } else {
                              setState(() {
                                textResult = data;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    Divider(),
                    InkWell(
                      child: Html(
                        data: textResult,
                        customRender: {
                          'ins': (RenderContext context,
                              Widget parsedChild,
                              Map<String, String> attributes,
                              dom.Element element) {
                            return Text(
                              element.text,
                              style: TextStyle(
                                  backgroundColor: Colors.yellowAccent),
                            );
                          }
                        },
                      ),
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: textResult));
                        showSuccessToast(context, '已复制');
                      },
                    )
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
                              '写作助手',
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
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(blankFocusNode);
      },
    );
  }
}
