/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:provider/provider.dart';
import 'package:toolspack/design_course/design_course_app_theme.dart';
import 'package:toolspack/main.dart';
import 'package:toolspack/utils/ui_tools.dart';
import 'package:toolspack_shared/model/get_agent_full_data.dart';
import 'package:toolspacklibs/model/login_cache.dart';
import 'package:toolspacklibs/utils/net_utils.dart';
import 'package:toolspacklibs/utils/wk_tools.dart';

class AgentPage extends StatefulWidget {
  static const routeName = "/SettingsPage";

  final FullAgentData agentData;

  AgentPage(this.agentData);

  @override
  State<StatefulWidget> createState() {
    return _AgentPage();
  }
}

class _AgentPage extends State<AgentPage> {
  var accController = TextEditingController();
  var accN = FocusNode();
  var passController = TextEditingController();
  var passN = FocusNode();

  @override
  void dispose() {
    accController.dispose();
    passController.dispose();
    accN.dispose();
    passN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginCacheModel =
        Provider.of<LoginCacheModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 100, bottom: 60),
              child: Column(children: <Widget>[
                ListTile(
                  title: Text('${widget.agentData.agentModelJson.spcode}'),
                  subtitle: Text('这是您的特征码'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.code,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.brown,
                  ),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (ctx) {
                      return AlertDialog(
                        title: Text('特征码'),
                        content: Text('特征码，用于辨识代理的唯一依据\n原则上不允许更改。'),
                        actions: <Widget>[
                          DialogUtil.getDialogCloseButton(context)
                        ],
                      );
                    });
                  },
                ),
                ListTile(
                  title: Text('${widget.agentData.agentModelJson.totalEarned}'),
                  subtitle: Text('这是一个阶段完成订单的金额'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.attach_money,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.pink,
                  ),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (ctx) {
                      return AlertDialog(
                        title: Text('阶段收益'),
                        content: Text('通过您的特征码所购买的商品的一个阶段累计金额，每次提现都会清空。\n'
                            '\n具体收益依照分成规定进行处理。'),
                        actions: <Widget>[
                          DialogUtil.getDialogCloseButton(context)
                        ],
                      );
                    });
                  },
                ),
                ListTile(
                  title: Text(
                      '${widget.agentData.agentModelJson.accumulatedprofit}'),
                  subtitle: Text('累计收入'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.monetization_on,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (ctx) {
                      return AlertDialog(
                        title: Text('累计收益'),
                        content: Text('这是您在我们平台上的累计收入，在阶段性收入清空后会并入累计收入。'),
                        actions: <Widget>[
                          DialogUtil.getDialogCloseButton(context)
                        ],
                      );
                    });
                  },
                ),
                ExpansionTile(
                  title: Text('完成的订单数量 ${widget.agentData.orders.length}'),
                  subtitle: Text('这是您旗下用户累计完成的订单数量'),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.bookmark,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.green,
                  ),
                  children: List<Widget>.generate(
                      widget.agentData.orders.length, (index) {
                    final order = widget.agentData.orders[index];
                    return ListTile(
                      title: Text('订单号: ${order.orderText}'),
                      subtitle: Text('金额: ${order.price}  '
                          '人工: ${!order.isBot}  '
                          '加急: ${order.needBoost}\n'
                          '日期: ${order.time}'),
                      contentPadding: EdgeInsets.only(bottom: 8, left: 16),
                    );
                  }),
                ),
                Divider(),
                ListTile(
                  title: Text('杂货修改'),
                  subtitle: Text('修改针对您所在的地区的特殊商品'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.apps,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.purpleAccent,
                  ),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (ctx) {
                      return AlertDialog(
                        title: Text('暂未开放'),
                        content: Text('暂未开放'),
                        actions: <Widget>[
                          DialogUtil.getDialogCloseButton(context)
                        ],
                      );
                    });
                  },
                ),
                ListTile(
                  title: Text('公告编辑'),
                  subtitle: Text('修改App首页公告，仅对您的特征码下的用户生效。'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.notifications_none,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.deepPurple,
                  ),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (ctx) {
                      final textController = TextEditingController();
                      return AlertDialog(
                        title: Text('编辑公告信息'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text('请遵守相关地区的法律法规，违规者封禁帐号并冻结收入。'),
                              TextField(
                                controller: textController,
                                decoration:
                                    InputDecoration(hintText: '100字以内。'),
                                maxLines: 4,
                              )
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          FlatButton(
                              onPressed: () async {
                                if (textController.text.length > 100) {
                                  showMyToast('内容过长！');
                                  return;
                                }

                                final loginCache = Provider.of<LoginCacheModel>(
                                    ctx,
                                    listen: false);

                                widget.agentData.agentModelJson.notice =
                                    textController.text;

                                DialogUtil.showBlurDialog(
                                    context,
                                    (context) =>
                                        LoadingDialog(text: '正在提交数据...'));

                                final res = await NetUtils4Wk.changeAgentData(
                                    widget.agentData.agentModelJson);
                                if (res) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  showMyToast('修改成功！');
                                } else {
                                  Navigator.pop(context);
                                  showMyToast('修改失败！请联系管理员。');
                                }
                              },
                              child: Text('提交')),
                          DialogUtil.getDialogCloseButton(context)
                        ],
                      );
                    });
                  },
                ),
                ListTile(
                  title: Text('优惠券管理'),
                  subtitle: Text('下发、删除优惠券'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.money_off,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.deepOrangeAccent,
                  ),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (context) {
                      List<dynamic> data =
                          json.decode(widget.agentData.agentModelJson.coupon);
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AlertDialog(
                            title: Text('优惠券列表'),
                            content: SingleChildScrollView(
                              child: Column(
                                children:
                                    List<Widget>.generate(data.length, (index) {
                                  var couponData = (data[index]);
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(couponData['code']),
                                        trailing: Icon(Icons.arrow_right),
                                        subtitle: Text(
                                            '剩余: ${couponData['times']}\n价值: ${couponData['val']}'),
                                        onTap: () {},
                                      ),
                                      Divider(),
                                    ],
                                  );
                                }),
                              ),
                            ),
                            actions: [
                              FlatButton(
                                  onPressed: () {
                                    DialogUtil.showBlurDialog(context, (ctx) {
                                      var valueNumber = 1.0;
                                      var valueVal = 1.0;
                                      return StatefulBuilder(
                                        builder: (context, setD2State) {
                                          return SimpleDialog(
                                            title: Text('请输优惠券信息'),
                                            children: <Widget>[
                                              Padding(
                                                padding:
                                                    UiTools.dialogEdgePadding,
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                        '优惠券数量: ${valueNumber.round()}'),
                                                    Slider(
                                                        value: valueNumber,
                                                        min: 1,
                                                        max: 10,
                                                        onChanged: (v) {
                                                          setD2State(() {
                                                            valueNumber = v;
                                                          });
                                                        }),
                                                    Text(
                                                        '优惠券价值: ${valueVal.round()}'),
                                                    Slider(
                                                        value: valueVal,
                                                        min: 1,
                                                        max: 3,
                                                        onChanged: (v) {
                                                          setD2State(() {
                                                            valueVal = v;
                                                          });
                                                        }),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: <Widget>[
                                                        FlatButton(
                                                            onPressed:
                                                                () async {
                                                              var code = WkTools
                                                                  .genCouponCode();
                                                              setDialogState(
                                                                  () {
                                                                data.add({
                                                                  'code': code,
                                                                  'times':
                                                                      valueNumber
                                                                          .round(),
                                                                  'val': valueVal
                                                                      .round()
                                                                });
                                                                widget
                                                                        .agentData
                                                                        .agentModelJson
                                                                        .coupon =
                                                                    json.encode(
                                                                        data);

                                                                printDebug4Wk(widget
                                                                    .agentData
                                                                    .agentModelJson
                                                                    .coupon);
                                                              });

                                                              DialogUtil
                                                                  .showBlurDialog(
                                                                      context,
                                                                      (ctx) {
                                                                return LoadingDialog(
                                                                    text:
                                                                        '正在发送数据...');
                                                              });
                                                              bool result;
                                                              result = await NetUtils4Wk
                                                                  .changeAgentData(widget
                                                                      .agentData
                                                                      .agentModelJson);

                                                              Navigator.pop(
                                                                  context);

                                                              if (result !=
                                                                      null &&
                                                                  result) {
                                                                Navigator.pop(
                                                                    context);
                                                                showSuccessToast(
                                                                    context,
                                                                    '修改成功');
                                                              } else {
                                                                showErrorToast(
                                                                    context,
                                                                    '修改失败');
                                                              }
                                                            },
                                                            child: Text(
                                                              '生成',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .red),
                                                            )),
                                                        DialogUtil
                                                            .getDialogCloseButton(
                                                                context)
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    });
                                  },
                                  child: Text('添加优惠券')),
                              DialogUtil.getDialogCloseButton(context),
                            ],
                          );
                        },
                      );
                    });
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('修改密码'),
                  subtitle: Text('修改您特征码所对应的密码'),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.red,
                  ),
                  trailing: Icon(Icons.arrow_right),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (ctx) {
                      var oldPassController = TextEditingController();
                      var newPassController = TextEditingController();

                      return SimpleDialog(
                        title: Text('修改代理密码'),
                        children: <Widget>[
                          Padding(
                            padding: UiTools.dialogEdgePadding,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 16, left: 16),
                                  child: TextField(
                                    controller: oldPassController,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    decoration:
                                        InputDecoration(hintText: '请输入旧密码'),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 16, left: 16),
                                  child: TextField(
                                    controller: newPassController,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    decoration:
                                        InputDecoration(hintText: '请输入新密码'),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                        onPressed: () async {
                                          if (kReleaseMode) {
                                            if (oldPassController
                                                    .text.isEmpty ||
                                                newPassController
                                                    .text.isEmpty) {
                                              showMyToast('请输入合法信息');
                                              return;
                                            }

                                            if (oldPassController.text.length <
                                                    6 ||
                                                newPassController.text.length <
                                                    6) {
                                              showMyToast('6位密码是必须的');
                                              return;
                                            }
                                          }

                                          DialogUtil.showBlurDialog(context,
                                              (ctx) {
                                            return LoadingDialog(
                                                text: '正在发送数据...');
                                          });
                                          var result;
                                          if (kReleaseMode) {
                                            result = await NetUtils4Wk
                                                .changeAgentPass(
                                                    widget.agentData
                                                        .agentModelJson.spcode,
                                                    oldPassController.text,
                                                    newPassController.text);
                                          } else {
//                                            result = await NetUtils4Wk
//                                                .changeAgentPass(
//                                                    'test_spcode_toolspack',
//                                                    '000000',
//                                                    'fu8093fhw098hf');
                                          }

                                          Navigator.pop(context);

                                          if (result != null && result) {
                                            Navigator.pop(context);
                                            showSuccessToast(context, '修改成功');
                                          } else {
                                            showErrorToast(context, '修改失败');
                                          }
                                        },
                                        child: Text(
                                          '修改',
                                          style: TextStyle(color: Colors.red),
                                        )),
                                    DialogUtil.getDialogCloseButton(context)
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      );
                    });
                  },
                ),
              ]),
            ),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                    color: DesignCourseAppTheme.nearlyWhite.withOpacity(0.8)),
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
                              color: DesignCourseAppTheme.grey,
                            ),
                          ),
                          Text(
                            '代理信息页面',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              letterSpacing: 0.27,
                              color: DesignCourseAppTheme.darkerText,
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
}
