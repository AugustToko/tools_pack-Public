/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:ota_update/ota_update.dart';
import 'package:provider/provider.dart';
import 'package:shared/config/global_settings.dart';
import 'package:toolspack/main.dart';
import 'package:toolspack/utils/shared_prefs.dart';
import 'package:toolspacklibs/model/login_cache.dart';
import 'package:toolspacklibs/utils/net_utils.dart';
import 'package:toolspacklibs/utils/wk_tools.dart';

import 'goto_pages.dart';

class UiTools {
  static const dialogEdgePadding = EdgeInsets.only(left: 16, right: 16);

  static Widget getBlurOverlay(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: double.infinity,
          height: 108,
          decoration: BoxDecoration(
              color:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8)),
        ),
      ),
    );
  }

  /// 显示更新对话框
  /// 不可取消
  /// [context]
  static Future<bool> showUpdateDialog(context) async {
    var targetApkUrl = 'URL_HERE';
    var fileName = 'toolsapck.apk';

    if (Platform.isAndroid) {
      final bool result =
          await GlobalSettings.channel.invokeMethod('canInstall'); // 2

      if (!result) {
        await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) {
              return WillPopScope(
                  child: AlertDialog(
                    title: Text('授权'),
                    content: Text('请打开允许安装未知来源应用程序，以确保APP更新功能正常使用'),
                    actions: <Widget>[
                      FlatButton(
                          onPressed: () async {
                            // 不可退出的阻塞 Dialog
                            final bool result = await GlobalSettings.channel
                                .invokeMethod('canInstall'); // 2
                            if (result) {
                              showMyToast('权限获取成功！');
                              Navigator.pop(context);
                            } else {
                              showMyToast('请打开允许安装未知来源应用程序');
                              await GlobalSettings.channel.invokeMethod(
                                  'requestInstallPermission'); // 2
                            }
                          },
                          child: Text('去授权/已授权')),
                      FlatButton(
                          onPressed: () {
                            exitApp(() {
                              if (loginCache.remoteSocket != null) {
                                loginCache.remoteSocket.close();
                              }
                            });
                          },
                          child: Text('退出 APP'))
                    ],
                  ),
                  onWillPop: () {
                    return Future.value(false);
                  });
            });
      }
    }

    return await showDialog<bool>(
        context: context,
        // 禁止取消
        barrierDismissible: false,
        builder: (ctx) {
          // 进度
          var progress = 0;
          var updateBtnPressed = false;
          return StatefulBuilder(builder: (ctx2, setDialogState) {
            if (Platform.isAndroid) {
              return SimpleDialog(
                title: Text('发现新版本'),
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 24, right: 24, top: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          updateBtnPressed
                              ? '正在更新, 请等待: $progress%'
                              : '这是一个不可规避的新版本，请下载安装！',
                          style: TextStyle(fontSize: 15),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 2,
                          child: LinearProgressIndicator(
                            value: progress.toDouble() / 100,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            FlatButton(
                                onPressed: updateBtnPressed
                                    ? null
                                    : () async {
                                        setDialogState(() {
                                          updateBtnPressed = true;
                                        });
                                        OtaUpdate()
                                            .execute(targetApkUrl,
                                                destinationFilename: fileName)
                                            .listen(
                                          (final OtaEvent event) {
                                            setDialogState(() {
                                              progress = int.parse(event.value);
                                            });
                                            debugPrint(
                                                'EVENT: ${event.status} : ${event.value}');
                                            if (event.value == '100') {
                                              showMyToast('APP 下载完成, 请安装更新！');
                                            }
                                          },
                                        );
                                      },
                                child: Text(
                                  '更新',
                                  style: TextStyle(
                                      color: updateBtnPressed
                                          ? Colors.grey
                                          : Theme.of(context).accentColor),
                                )),
                            FlatButton(
                                onPressed: () {
                                  exitApp(() {
                                    if (loginCache.remoteSocket != null) {
                                      loginCache.remoteSocket.close();
                                    }
                                  });
                                },
                                child: Text(
                                  '退出',
                                  style: TextStyle(color: Colors.red),
                                ))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              );
            } else {
              return AlertDialog(
                title: Text('发现新版本'),
                content: Text('请更新后再使用本App'),
                actions: <Widget>[DialogUtil.getDialogCloseButton(context)],
              );
            }
          });
        });
  }

  static void showPayHelpDialog(final BuildContext context) {
    DialogUtil.showBlurDialog(context, (ctx) {
      return AlertDialog(
        title: Text('帮助内容'),
        content: Text('1. 如课程并非是一次性更新完成的，那么会自动刷新新课程。无需二次付款\n\n'
            '2. 在支付宝付款完成后，请务必选择已付款。否则造成的掉单等现象本 APP 概不负责。\n\n'
            '3. 付费是按照一门课进行计算，无视该课程完成度。\n\n'
            '4. 不支持简答题、慕课互评、等主观题。\n\n'
            '5. 知到每天刷半小时，保证结课之前完成，见面课不是当时安排，会在之后看回放。'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('关闭'))
        ],
      );
    });
  }

  static void showLoginHelpDialog(final BuildContext context) {
    //TODO: 登录帮助
    DialogUtil.showBlurDialog(context, (ctx) {
      return AlertDialog(
        title: Text('帮助内容'),
        content: Text(
            '学校为你平台上所对应的学校\n\n账号为你的平台账号\n\n密码为你的平台密码\n\n默认平台为超星平台，可以点击\“当前平台：超星\”来更换你想操作的平台\n\n特征码与平台无关联性。'),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('关闭'))
        ],
      );
    });
  }

  /// 展示我的信息
  /// [context]
  /// [data] 已登录学生信息列表
  /// [payInfoPack] 最近订单列表
  static Future<bool> showMyMsgDialog(
      final context, final LoginCacheModel loginCacheModel) {
    return DialogUtil.showBlurDialog<bool>(context, (ctx) {
      final data = loginCacheModel.studentLoginList;

      final title = Text('我的信息');

      // 最近订单按钮
      final recentOrderListBtn = FlatButton(
          onPressed: () => UiTools.showRecentPayList(context),
          child: Text('最近订单列表', style: TextStyle(color: Colors.orange)));

      // TODO: 自定义特征码
      // 特征码按钮
      final spcodeBtn = FlatButton(
          onPressed: () {
            DialogUtil.showBlurDialog(context, (crx) {
              var controller = TextEditingController();
              controller.text = loginCacheModel.spcode;
              return AlertDialog(
                title: Text('我的特征码'),
                content: TextField(
                  controller: controller,
                  keyboardType: TextInputType.visiblePassword,
                  maxLines: 2,
                  decoration: InputDecoration(hintText: '特征码（可选）'),
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () async {
                        if (controller.text == null ||
                            controller.text.trim().isEmpty) {
                          showErrorToast(context, '请输入合法特征码');
                          return;
                        }

                        // 更新 pack data
                        final packData = await NetUtils4Wk.getToolsPackData(
                            spcode: loginCacheModel.spcode);

                        if (packData == null ||
                            packData.agentModel == null ||
                            packData.agentModel.priceP1 == -1 ||
                            packData.agentModel.priceP2 == -1) {
                          showErrorToast(context, '特征码错误');
                        } else {
                          // 更新 spcode
                          loginCacheModel.spcode = controller.text;

                          await SharedPreferenceUtil.setString(
                              SP_SPCODE, controller.text);

                          loginCacheModel.packData = packData;
                          Navigator.pop(context);
                          showSuccessToast(context, '更新成功');
                        }
                      },
                      child: Text('更新')),
                  DialogUtil.getDialogCloseButton(context)
                ],
              );
            });
          },
          child: Text('我的特征码', style: TextStyle(color: Colors.greenAccent)));

      return StatefulBuilder(
        builder: (ctx, setDialogState) {
          final continueLoginBtn = FlatButton(
              onPressed: () async {
                showErrorToast(context, '暂不开放!');
//                if (data.length == loginCacheModel.packData.platforms.length) {
//                  showErrorToast(context, '所有平台都已登录完成!');
//                } else {
//                  final StudentInfoUnit val = await gotoLoginPage(ctx);
//                  // 如果登录成功且返回数据合法，那么刷新 Dialog
//                  if (val != null) {
//                    setDialogState(() {});
//                  }
//                }
              },
              child: Text(
                '追加登录',
                style: TextStyle(color: Colors.green),
              ));

          if (data.length > 1) {
            return SimpleDialog(
              contentPadding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 8),
              title: title,
              children: <Widget>[
                const SizedBox(
                  height: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List<Widget>.generate(data.length, (index) {
                    final selectedStudentInfo = data[index];

                    return ListTile(
                      title: Text(selectedStudentInfo.obj.platformType.name),
                      subtitle: Text('${selectedStudentInfo.obj.userName}'),
                      // 打开单个详情页面
                      onTap: () async {
                        var done = await DialogUtil.showBlurDialog<bool>(
                            context, (ctx) {
                          return AlertDialog(
                            title: title,
                            content: Text(
                                '学校: ${selectedStudentInfo.obj.schoolName}\n姓名: ${selectedStudentInfo.obj.userName}\n账户: ${selectedStudentInfo.obj.account}\n' +
                                    '平台: ${selectedStudentInfo.obj.platformType.name}'),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () {
                                    loginCacheModel
                                        .removeStudent(selectedStudentInfo);
                                    Navigator.pop(context, true);
                                  },
                                  child: Text(
                                    '退出登录',
                                    style: TextStyle(color: Colors.redAccent),
                                  )),
                              DialogUtil.getDialogCloseButton(context,
                                  customTapFunc: () {
                                Navigator.pop(context, null);
                              }),
                            ],
                          );
                        });

                        // 如果成功登出，那么刷新 Dialog
                        if (done != null && done) setDialogState(() {});
                      },
                    );
                  }),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    // TODO: 有时候需要点两次才能退出 Dialog
                    DialogUtil.getDialogCloseButton(context),
                    continueLoginBtn,
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
//                    spcodeBtn,
                    recentOrderListBtn,
                  ],
                )
              ],
            );
          } else {
            return AlertDialog(
              title: title,
              content: Text(
                  '学校: ${data[0].obj.schoolName}\n姓名: ${data[0].obj.userName}\n账户: ${data[0].obj.account}\n' +
                      '平台: ${data[0].obj.platformType.name}'),
              actions: <Widget>[
                DialogUtil.getDialogCloseButton(context),
                continueLoginBtn,
                FlatButton(
                    onPressed: () {
                      loginCacheModel.removeCurrentStudent();
                      Navigator.pop(context);
                    },
                    child: Text(
                      '退出登录',
                      style: TextStyle(color: Colors.redAccent),
                    )),
//                spcodeBtn,
                recentOrderListBtn,
              ],
            );
          }
        },
      );
    });
  }

  /// 展示最近订单
  static void showRecentPayList(final BuildContext context) {
    final loginCacheModel =
        Provider.of<LoginCacheModel>(context, listen: false);
    var payInfoPack = loginCacheModel.recentOrders;

    DialogUtil.showBlurDialog(context, (ctx) {
      // 添加订单item
      var orderItemWidgets = List<Widget>.generate(payInfoPack.length, (index) {
        var payInfo = payInfoPack[index];

        var title = payInfo.cartDataListToString();
        var subtitle =
            '订单价格: ${payInfo.price}\n订单编号: ${payInfo.readPayInfo.orderText}\n时间: ${payInfo.date}';

        return Column(
          children: <Widget>[
            ListTile(
              isThreeLine: true,
              title: Text('$title'),
              subtitle: Text(subtitle),
              onTap: () {
                WkTools.query(context, payInfo.readPayInfo.orderText);
              },
            ),
            Divider()
          ],
        );
      });

      orderItemWidgets.add(Padding(
        padding: dialogEdgePadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FlatButton(
                onPressed: () {
                  DialogUtil.showBlurDialog(context, (ctx) {
                    return SimpleDialog(
                      title: Text('历史订单'),
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Column(
                            children: <Widget>[
                              Text('点击项目，查看订单详情。'),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          ),
                        ),
                        Column(
                          children: List<Widget>.generate(
                              loginCacheModel.recentOrdersHistory.length,
                              (index) {
                            // 被点击的历史订单
                            final item =
                                loginCacheModel.recentOrdersHistory[index];

                            return ListTile(
                              contentPadding:
                                  const EdgeInsets.only(bottom: 10, left: 16),
                              title: Text('${++index} 订单号：${item.orderText}'),
                              subtitle:
                                  Text('价格：${item.price}\n时间：${item.date}'),
//                                leading: CircleAvatar(
//                                  child: Text('$index'),
//                                ),
                              onTap: () async {
                                WkTools.query(context, item.orderText);

//                                DialogUtil.showBlurDialog(context, (ctx) {
//                                  return LoadingDialog(text: '加载中...');
//                                });
//
//                                var data =
//                                    await NetUtils4Wk.getCourseDataByOrderText(
//                                        item.orderText);
//
//                                Navigator.pop(context);
//
//                                if (data != null) {
//                                  DialogUtil.showBlurDialog(context, (ctx) {
//                                    return AlertDialog(
//                                      title: Text('查询结果'),
//                                      content: Column(
//                                        children: <Widget>[
//                                          Text(data.orderText),
//                                          Text(item.price),
//                                          Text(data.time),
//                                          Text(data.stuObj
//                                              .getCheckedCourseListString()),
//                                        ],
//                                      ),
//                                    );
//                                  });
//                                } else {
//                                  showToastNative('从服务器获取数据失败！');
//                                }
                              },
                            );
                          }),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              DialogUtil.getDialogCloseButton(context)
                            ],
                          ),
                        )
                      ],
                    );
                  });
                },
                child: Text('显示历史订单')),
            DialogUtil.getDialogCloseButton(context),
          ],
        ),
      ));

      return SimpleDialog(
        title: Text('最近订单列表'),
        children: orderItemWidgets,
      );
    });
  }

  static Future<void> showChangelogDialog(final BuildContext context) async {
    DialogUtil.showBlurDialog(context, (ctx) {
      return LoadingDialog(text: '正在加载...');
    });

    final message = await rootBundle.loadString('assets/changelog.tplog');

    Navigator.pop(context);

    await DialogUtil.showBlurDialog(context, (ctx) {
      return AlertDialog(
        title: Text('更新记录'),
        content: SingleChildScrollView(
          child: Text(message),
        ),
        actions: <Widget>[DialogUtil.getDialogCloseButton(context)],
      );
    });
  }
}
