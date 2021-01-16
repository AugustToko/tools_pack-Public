/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:super_qr_reader/super_qr_reader.dart';
import 'package:toolspack/main.dart';
import 'package:toolspack_shared/model/payInfo.dart';
import 'package:toolspack_shared/model/student_info.dart';
import 'package:toolspacklibs/utils/net_utils.dart';
import 'package:toolspacklibs/utils/wk_tools.dart';
import 'package:websocket_manager/websocket_manager.dart';

class OrderCheckPage extends StatefulWidget {
  final String date;

  final PrePayInfo readyPayInfo;

  final noticeStyle = TextStyle(fontWeight: FontWeight.bold);

  final Function(PayInfo payInfo) buy;

  OrderCheckPage({Key key, this.date, this.readyPayInfo, this.buy})
      : super(key: key);

  @override
  _OrderCheckPageState createState() => _OrderCheckPageState();
}

class _OrderCheckPageState extends State<OrderCheckPage> {
  /* ------------ CouponCode ------------*/

  /// 优惠券代码
  var oldCouponCode = '';

  /// 优惠券价值
  var oldCouponVal = 0;

  /// 优惠券代码
  var couponCode = '';

  /// 优惠券价值
  var couponVal = 0;

  /* ------------ CouponCode ------------*/

  var couponTextController = TextEditingController();

  /// 是否显示查询按钮
  var enableQueryButton = false;

  /// 是否为人工价格
  var chooseManualPrice = false;

  /// 记录错误
  var error = false;

  /// 加急
  var boost = false;

  /// 课程数量
  var courseNum = 0;

  /// 用于显示价格
  var basePrice = 0.0;

  final selectedCourseList = <StuObjInfo>[];

  /// 团购 ID，等同为开团订单号
  String groupId = '';

  /// 是否为主持开团者
  bool groupHost = false;

  WebsocketManager remoteSocket;

  void initPrice() {
    selectedCourseList.clear();
    basePrice = 0;
    courseNum = 0;

    // 计算价格
    widget.readyPayInfo.dataList.forEach((stuObj) {
      // 差错
      if (stuObj.platformType == null ||
          stuObj.courseList.isEmpty ||
          stuObj.checkedCourseList.isEmpty) {
        error = true;
      }

      // 如果无错计入列表
      if (!error) {
        selectedCourseList.add(stuObj);

        // 从 packdata 中获取单价
        final tempPrice = WkTools.fromAgent2Price(
            widget.readyPayInfo.packData.agentModel, stuObj.platformType.id);

        // 计算课程数目
        courseNum += stuObj.checkedCourseList.length;

        // 最初价格
        basePrice += (tempPrice * stuObj.checkedCourseList.length);
      }

      if (error) {
        DialogUtil.showBlurDialog(
            context,
            (context) => AlertDialog(
                  title: Text('课程信息有误'),
                  content: Text('请检查您的账号或所选的课程'),
                  actions: <Widget>[
                    DialogUtil.getDialogCloseButton(context, customTapFunc: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })
                  ],
                ),
            barrierDismissible: false);
      }
    });
  }

  @override
  void initState() {
    remoteSocket = loginCache.remoteSocket;

    initPrice();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      loginCache.callBacks.add((event) {
        final eventData = event.split('&AND&');
        if (eventData.length != 3) return;

        if (eventData[0] == '@ADDGROUP') {
          // 验证订单信息
          if (widget.readyPayInfo.orderText != eventData[1]) return;

          final c2s = CoursePack2Server.fromJson(json.decode(eventData[2]));

          // 验证账号
          if (widget.readyPayInfo.dataList.length > 0 && c2s.user.length > 0) {
            if (c2s.user[0].account ==
                widget.readyPayInfo.dataList[0].account) {
              showErrorToast(context, '请勿使用相同账号加入团购');
            } else {
              setState(() {
                widget.readyPayInfo.dataList.addAll(c2s.user);
                initPrice();
              });
              showSuccessToast(context, '成功加入团购');
            }
          } else {
            showErrorToast(context, '数据异常');
          }
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var price = basePrice;
    // 下单完成的数据
    var payData = PayInfo(widget.readyPayInfo, !chooseManualPrice, boost, price,
        widget.date, couponCode);

    var mainButton = (groupId.isNotEmpty && !groupHost)
        ? Column(
            children: [
              const Text(
                '已参团',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(
                height: 15,
              )
            ],
          )
        : Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
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
                            Radius.circular(16.0),
                          ),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Colors.white,
                                offset: const Offset(1.1, 1.1),
                                blurRadius: 10.0),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            enableQueryButton ? '查询订单状态' : '购买',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
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
                              Radius.circular(16.0),
                            ),
                            child: Container(),
                            onTap: enableQueryButton
                                ? () {
                                    WkTools.query(
                                        context, widget.readyPayInfo.orderText);
                                  }
                                : () {
                                    widget.buy(payData);
                                    setState(() {
                                      enableQueryButton = true;
                                    });
                                  },
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            // 保证 bottom 不会被下拉而退出
            SizedBox(
              height: MediaQuery.of(context).size.height * 1.05,
            ),
            Column(
//                  mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 55,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.warning,
                      size: 30,
                      color: Colors.deepOrange,
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    const Text(
                      '支付确认',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                const Divider(),
                ListTile(
                  title: Text(
                    "价钱: ",
                    style: widget.noticeStyle,
                  ),
                  trailing: Text(
                    couponVal == 0
                        ? '${price.toStringAsFixed(2)}'
                        : '${(price - couponVal).toStringAsFixed(2)} (已优惠 $couponVal 元)',
                    style: widget.noticeStyle,
                  ),
                ),
                ListTile(
                  title: Text("商家订单编号: ", style: widget.noticeStyle),
                  subtitle: Text('点击拷贝订单号', style: widget.noticeStyle),
                  trailing: Text('${widget.readyPayInfo.orderText}',
                      style: widget.noticeStyle),
                  onTap: () {
                    Clipboard.setData(
                        ClipboardData(text: widget.readyPayInfo.orderText));
                    showMyToast('已复制');
                  },
                ),
                Column(
                  children:
                      List<Widget>.generate(selectedCourseList.length, (index) {
                    // 获取目标学生信息
                    final targetStuObj = selectedCourseList[index];

                    // 获取目标学生信息平台
                    var platform = targetStuObj.platformType;

                    // 获取目标学生信息的选中课程
                    var checkedCourseList = targetStuObj.checkedCourseList;

                    return ExpansionTile(
                      title: Text(
                          '${platform.name} (${targetStuObj.userName}, ${targetStuObj.checkedCourseList.length}门课)'),
                      children: List<Widget>.generate(checkedCourseList.length,
                          (index2) {
                        Widget removeBtn = const SizedBox();
                        // 仅团购允许变动课程
                        if (index2 == checkedCourseList.length - 1 &&
                            groupId != null &&
                            groupId.isNotEmpty) {
                          removeBtn = ListTile(
                            title: Text(
                              '删除此平台所有课程',
                              style: TextStyle(color: Colors.red),
                            ),
                            onTap: () {
                              if (selectedCourseList.length == 1) {
                                showMyToast('至少保留一个！');
                              } else {
                                widget.readyPayInfo.dataList
                                    .remove(targetStuObj);
                                initPrice();
                                setState(() {});
                              }
                            },
                          );
                        }

                        var courseData = checkedCourseList[index2];
                        return Column(
                          children: <Widget>[
                            ListTile(
                              title: Text(courseData.courseName),
                              trailing: Text("总章节: ${courseData.chapterCount}"),
//                                  onTap: () {},
                              subtitle: Text(
                                  '${targetStuObj.schoolName}  ${targetStuObj.userName}  ${targetStuObj.account}'),
                            ),
                            removeBtn
//                                ListTile(
//                                  title: Text("课程名称:"),
//                                  trailing: Text(
//                                      '${courseData.getCourseData().courseName}'),
//                                  subtitle: Text(
//                                      '章节数量: ${courseData.getCourseData().chapterCount}'),
//                                  onTap: () {},
//                                ),
//                                ListTile(
//                                  title: Text("目标用户名: "),
//                                  trailing:
//                                      Text("${courseData.stuObjInfo.userName}"),
//                                  onTap: () {},
//                                ),
                          ],
                        );
                      }),
                    );
                  }),
                ),
                Divider(),
                Column(children:
//                  (group == null || group.isEmpty) ?
                        [
                  CheckboxListTile(
                    secondary: Icon(FontAwesomeIcons.user),
                    title: Text("使用人工安全操作"),
                    subtitle: Text(
                        '每门课原价加${widget.readyPayInfo.packData.previewManualPrice}元。\n机器操作安全度非常高，目前并没有接到封号投诉。'),
                    selected: true,
                    value: chooseManualPrice,
                    onChanged: (val) {
                      setState(() {
                        chooseManualPrice = val;
                        if (val) {
                          basePrice += courseNum * 2;
                          price = basePrice;
                        } else {
                          basePrice -= courseNum * 2;
                          price = basePrice;
                        }
                      });
                    },
                  ),
                  CheckboxListTile(
                    secondary: Icon(FontAwesomeIcons.fastForward),
                    title: Text("加急处理"),
                    subtitle: Text(
                        '每门课原价加${widget.readyPayInfo.packData.previewManualPrice}元。\n将第一时间处理您的订单。'),
                    selected: true,
                    activeColor: Colors.orange,
                    value: boost,
                    onChanged: (val) {
                      setState(() {
                        boost = val;
                        if (val) {
                          basePrice += courseNum * 2;
                          price = basePrice;
                        } else {
                          basePrice -= courseNum * 2;
                          price = basePrice;
                        }
                      });
                    },
                  ),
                  Divider(),
                  SwitchListTile(
                      title: const Text("使用优惠券: "),
                      subtitle: Text(couponCode.isEmpty
                          ? '该订单支持使用优惠券'
                          : '优惠券代码: $couponCode'),
                      value: couponVal != 0,
                      secondary: const Icon(
                        FontAwesomeIcons.ticketAlt,
                        color: Colors.green,
                      ),
                      // 团购不允许优惠券操作
                      onChanged: (groupId == null || groupId.isEmpty)
                          ? (val) async {
                              // 如果没有填过优惠券信息
                              if (oldCouponCode.isEmpty && oldCouponVal == 0) {
                                Map<String, dynamic> tempCode = await DialogUtil
                                    .showBlurDialog<Map<String, dynamic>>(
                                        context, (context) {
                                  return AlertDialog(
                                    title: const Text('输入优惠券代码'),
                                    content: Wrap(
                                      children: [
                                        Column(
                                          children: [
                                            TextField(
                                              controller: couponTextController,
                                              maxLines: 1,
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                  hintText: '请输入优惠券代码'),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                    actions: [
                                      FlatButton(
                                          onPressed: () async {
                                            var temp = await NetUtils4Wk
                                                .checkCouponData(
                                                    payData.readPayInfo.packData
                                                        .agentModel.spcode,
                                                    couponTextController.text);
                                            if (temp['result']) {
                                              var finalCouponText = {
                                                'code':
                                                    couponTextController.text,
                                                'val': temp['val']
                                              };
                                              Navigator.pop(
                                                  context, finalCouponText);
                                            } else {
                                              showErrorToast(
                                                  context, '优惠券校验错误！');
                                            }
                                          },
                                          child: const Text('确认')),
                                      DialogUtil.getDialogCloseButton(context)
                                    ],
                                  );
                                });
                                if (tempCode != null &&
                                    tempCode['code'].isNotEmpty) {
                                  setState(() {
                                    couponCode = tempCode['code'];
                                    couponVal = tempCode['val'];

                                    oldCouponCode = couponCode;
                                    oldCouponVal = couponVal;

                                    // 更新
                                    payData.couponCode = couponCode;
                                  });
                                }
                              } else {
                                if (val) {
                                  setState(() {
                                    couponVal = oldCouponVal;
                                    couponCode = oldCouponCode;
                                    payData.couponCode = couponCode;
                                  });
                                } else {
                                  payData.couponCode = '';
                                  setState(() {
                                    couponVal = 0;
                                    couponCode = '';
                                  });
                                }
                              }
                            }
                          : null),
                ]
//                      : [
//                          ListTile(
//                            title: const Text("仅开团者方可选择人工或加急"),
////                            trailing: const Icon(Icons.arrow_right),
//                            subtitle: const Text('作为参团者，您无法控制人工或加急'),
//                            leading: const Icon(
//                              FontAwesomeIcons.npm,
//                              color: Colors.deepPurple,
//                            ),
//                            onTap: () {
//                              WkTools.showPayHelpDialog(context);
//                            },
//                          ),
//                        ],
                    ),
                ListTile(
                  enabled: couponCode.isEmpty && !kReleaseMode,
                  title: const Text("组团购买: "),
                  trailing: const Icon(Icons.arrow_right),
                  subtitle: const Text('多人一起组团优惠购买'),
                  selected: groupHost,
                  leading: const Icon(
                    FontAwesomeIcons.handshake,
                    color: Colors.cyan,
                  ),
                  onTap: () async {
                    DialogUtil.showBlurDialog(context, (context) {
                      return AlertDialog(
                        title: Text('组团购买'),
                        content: Text('选择你的组团方式'),
                        actions: [
                          FlatButton(
                              onPressed: () async {
                                final String results = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ScanView(),
                                  ),
                                );

                                if (results != null) {
                                  Navigator.pop(context);
                                  remoteSocket.send(
                                      '@CANTUAN&AND&$results&AND&${json.encode(getC2S(payData))}');

                                  // update ui
                                  setState(() {
                                    groupId = results;
                                  });

                                  showSuccessToast(context, '成功加入团购');
                                } else {
                                  showErrorToast(context, '识别二维码失败！');
                                }
                              },
                              child: Text('加入团购')),
                          // ---------------------------
                          FlatButton(
                              onPressed: () async {
                                Navigator.pop(context);

                                if (groupId.isEmpty) {
                                  remoteSocket.send(
                                      '@KAITUAN&AND&${payData.readPayInfo.orderText}&AND&${json.encode(getC2S(payData))}');
                                  setState(() {
                                    groupId = payData.readPayInfo.orderText;
                                    groupHost = true;
                                  });
                                }

                                DialogUtil.showBlurDialog(context, (context) {
                                  return AlertDialog(
                                    title: Text('团购二维码'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            child: QrImage(
                                              data:
                                                  payData.readPayInfo.orderText,
                                              version: QrVersions.auto,
                                              size: 200.0,
                                            ),
                                            height: 200,
                                            width: 200,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                              '订单号:\n ${payData.readPayInfo.orderText}'),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Text('用手机扫描此二维码加入团购\n'
                                              '注意事项:\n'
                                              '①仅限相同特征码用户参与！\n'
                                              '②每个团购二维码有效期为10分钟，过期后需要重新下单。\n'
                                              '③目前团购不支持与优惠券叠加使用。\n'
                                              '④不支持相同账号加入团购。')
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      DialogUtil.getDialogCloseButton(context)
                                    ],
                                  );
                                });
                              },
                              child: Text('发起团购')),
                          FlatButton(
                              onPressed: () {
                                WkTools.showGroupPayHelpDialog(context);
                              },
                              child: Text('帮助'))
                        ],
                      );
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text("帮助: "),
                  trailing: const Icon(Icons.arrow_right),
                  subtitle: const Text('遇到问题？'),
                  leading: const Icon(
                    FontAwesomeIcons.handsHelping,
                    color: Colors.redAccent,
                  ),
                  onTap: () {
                    WkTools.showPayHelpDialog(context);
                  },
                ),
                const SizedBox(
                  height: 100,
                ),
                mainButton,
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    '取消付款',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

CoursePack2Server getC2S(PayInfo payedInfo) {
  return CoursePack2Server(
      payedInfo.readPayInfo.dataList,
      payedInfo.needBoost ? 1 : 0,
      payedInfo.readPayInfo.packData.agentModel.spcode,
      payedInfo.readPayInfo.orderText,
      payedInfo.isBot,
      payedInfo.couponCode);
}
