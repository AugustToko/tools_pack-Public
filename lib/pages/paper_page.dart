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
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:toolspacklibs/utils/net_utils.dart';

import '../main.dart';

class PaperPage extends StatefulWidget {
  @override
  _PaperPageState createState() => _PaperPageState();
}

/// 写作风格
enum PaperStyle {
  ///宽松
  Loose,

  /// 严格
  rigorous,
}

/// 写作字数
enum PaperCount { _1k5, _2k, _3k }

class _PaperPageState extends State<PaperPage> {
  final titleController = TextEditingController();

  final FocusNode blankFocusNode = FocusNode();

  PaperStyle _paperStyle;

  PaperCount _paperCount;

  final keys = <String>[];

  var textResult = 'Empty';

  String paperStyleToString(final PaperStyle paperStyle) {
    switch (paperStyle) {
      case PaperStyle.Loose:
        return '宽松';
      case PaperStyle.rigorous:
        return '严格';
    }
    return '';
  }

  int paperCountToInt(final PaperCount paperCount) {
    switch (paperCount) {
      case PaperCount._1k5:
        return 1500;
      case PaperCount._2k:
        return 2000;
      case PaperCount._3k:
        return 3000;
    }
    return 0;
  }

  String keyToString() {
    var result = '';
    keys.forEach((element) {
      result += '$element+';
    });
    return result.substring(0, result.length - 1);
  }

  @override
  void initState() {
    super.initState();
    _paperStyle = PaperStyle.Loose;
    _paperCount = PaperCount._1k5;
  }

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
                        controller: titleController,
                        decoration: InputDecoration(hintText: '论文标题'),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: <Widget>[
                        MaterialButton(
                          child: Text('添加关键字'),
                          onPressed: () {
                            if (keys.length >= 3) {
                              showMyToast('免费版仅支持三个关键字');
                              return;
                            }

                            DialogUtil.showBlurDialog(context, (context) {
                              final ctl = TextEditingController();
                              return AlertDialog(
                                title: Text('请输入关键字'),
                                content: TextField(
                                  controller: ctl,
                                  decoration:
                                      InputDecoration(hintText: '论文关键字'),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                      onPressed: () {
                                        if (ctl.text.isEmpty) {
                                          showMyToast('请输入合法内容');
                                          return;
                                        }

                                        keys.add(ctl.text);
                                        Navigator.pop(context);
                                        setState(() {});
                                      },
                                      child: Text('确认')),
                                  DialogUtil.getDialogCloseButton(context)
                                ],
                              );
                            });
                          },
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                        ),
                        SizedBox(
                          width: 12,
                        ),
                        Row(
                          children: List<Widget>.generate(
                            keys.length,
                            (index) {
                              return ChoiceChip(
                                label: Text(keys[index]),
                                selected: true,
                                onSelected: (val) {
                                  setState(() {
                                    keys.remove(keys[index]);
                                  });
                                },
                              );
                            },
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    PopupMenuButton<PaperStyle>(
                      initialValue: PaperStyle.Loose,
                      tooltip: '写作风格',
                      onSelected: (val) {
                        setState(() {
                          _paperStyle = val;
                        });
                      },
                      itemBuilder: (context) => <PopupMenuItem<PaperStyle>>[
                        PopupMenuItem<PaperStyle>(
                          value: PaperStyle.Loose,
                          child: Text('宽松'),
                        ),
                        PopupMenuItem<PaperStyle>(
                          value: PaperStyle.rigorous,
                          child: Text('严格'),
                        ),
                      ],
                      child: ListTile(
                        title: Text('写作风格'),
                        subtitle:
                            Text('当前论文风格: ${paperStyleToString(_paperStyle)}'),
                      ),
                    ),
                    PopupMenuButton<PaperCount>(
                      initialValue: PaperCount._1k5,
                      tooltip: '写作字数',
                      onSelected: (val) {
                        setState(() {
                          _paperCount = val;
                        });
                      },
                      itemBuilder: (context) => <PopupMenuItem<PaperCount>>[
                        PopupMenuItem<PaperCount>(
                          value: PaperCount._1k5,
                          child:
                              Text(paperCountToInt(PaperCount._1k5).toString()),
                        ),
                        PopupMenuItem<PaperCount>(
                          value: PaperCount._2k,
                          child:
                              Text(paperCountToInt(PaperCount._2k).toString()),
                        ),
                        PopupMenuItem<PaperCount>(
                          value: PaperCount._3k,
                          child:
                              Text(paperCountToInt(PaperCount._3k).toString()),
                        ),
                      ],
                      child: ListTile(
                        title: Text('论文字数'),
                        subtitle:
                            Text('当前论文字数: ${paperCountToInt(_paperCount)}'),
                      ),
                    ),
                    Divider(),
                    InkWell(
                      child: Text(textResult),
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
                              '论文助手',
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
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.check),
            onPressed: () async {
              if (titleController.text.isEmpty) {
                showMyToast('论文标题为空');
                return;
              }

              DialogUtil.showBlurDialog(
                  context,
                  (context) => LoadingDialog(
                        text: '正在加载...',
                        cancelable: true,
                      ));

              final data = await NetUtils4Wk.getPaperResult(
                  'UdGezYjAnfBhlqUX',
                  '${keyToString()}',
                  '${titleController.text}',
                  paperCountToInt(_paperCount),
                  paperStyleToString(_paperStyle));

              Navigator.pop(context);

              if (data == null) {
                showErrorToast(context, '获取失败，请检查或更换关键词、标题');
              } else {
                var text = '        ';

                data.text.forEach((element) {
                  text += '$element\n        ';
                });

                setState(() {
                  textResult = text;
                });
              }
            }),
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(blankFocusNode);
      },
    );
  }
}
