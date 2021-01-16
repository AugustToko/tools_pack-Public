/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:provider/provider.dart';
import 'package:shared/config/global_settings.dart';
import 'package:toolspack/main.dart';
import 'package:toolspack/pages/about_app_wk.dart';
import 'package:toolspack/pages/agent_page.dart';
import 'package:toolspack/pages/intor_page.dart';
import 'package:toolspack/pages/permission_page.dart';
import 'package:toolspack/utils/shared_prefs.dart';
import 'package:toolspack/utils/ui_tools.dart';
import 'package:toolspack_shared/model/get_agent_full_data.dart';
import 'package:toolspacklibs/model/login_cache.dart';
import 'package:toolspacklibs/utils/net_utils.dart';
import 'package:toolspacklibs/utils/wk_tools.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

/// [MainPage]
/// 仅带有一个 BottomNavigationBar
class SettingsPage extends StatefulWidget {
  static const routeName = '/SettingsPage';

  @override
  State<StatefulWidget> createState() {
    return _DebugPagePageState();
  }
}

class _DebugPagePageState extends State<SettingsPage> {
  var accController = TextEditingController();
  var accN = FocusNode();
  var passController = TextEditingController();
  var passN = FocusNode();

  final FocusNode myFocusNodeSchoolLogin = FocusNode();
  final FocusNode myFocusNodeSpcodeLogin = FocusNode();
  final FocusNode myFocusNodeEmailLogin = FocusNode();
  final FocusNode myFocusNodePasswordLogin = FocusNode();

  TextEditingController loginSchoolController = TextEditingController();
  TextEditingController loginSpcodeController = TextEditingController();
  TextEditingController loginEmailController = TextEditingController();
  TextEditingController loginPasswordController = TextEditingController();

  bool _obscureTextLogin = true;

  @override
  void dispose() {
    super.dispose();
    accController.dispose();
    passController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loginCacheModel =
        Provider.of<LoginCacheModel>(context, listen: false);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 100, bottom: 60),
              child: Column(children: <Widget>[
                ListTile(
                  title: Text('代理登录'),
                  subtitle: Text('使用代理账号信息登录'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.fingerprint,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.teal,
                  ),
                  onTap: () async {
                    accController.text =
                        await SharedPreferenceUtil.getString(SP_AGENTACC);
                    passController.text =
                        await SharedPreferenceUtil.getString(SP_AGENTPASS);
                    DialogUtil.showBlurDialog(context, (ctx) {
                      return SimpleDialog(
                        title: Text('请输入代理信息'),
                        children: <Widget>[
                          Padding(
                            padding: UiTools.dialogEdgePadding,
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(right: 16, left: 16),
                                  child: TextField(
                                    controller: accController,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    decoration:
                                        InputDecoration(hintText: '请输入特征码'),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 16, left: 16),
                                  child: TextField(
                                    controller: passController,
                                    maxLines: 1,
                                    keyboardType: TextInputType.text,
                                    decoration:
                                        InputDecoration(hintText: '请输入密码'),
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          gotoAgentPage();
                                        },
                                        child: Text(
                                          '登录',
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
                ListTile(
                  title: Text('查询订单状态'),
                  subtitle: Text('手动查询订单状态'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.pinkAccent,
                  ),
                  onTap: () {
                    DialogUtil.showBlurDialog(context, (ctx) {
                      var controller = TextEditingController();
                      return SimpleDialog(
                        title: Text('请输入商家订单号'),
                        children: <Widget>[
                          Padding(
                            padding: UiTools.dialogEdgePadding,
                            child: Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  '如果您丢失订单号，我们概不负责',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 16, left: 16),
                                  child: TextField(
                                    controller: controller,
                                    maxLines: 1,
                                    keyboardType: TextInputType.number,
                                    decoration:
                                        InputDecoration(hintText: '输入合法的订单号'),
                                  ),
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          printDebug4Wk(
                                              '====== CAN QUERY: ${loginCacheModel.canQuery}');
                                          if (!loginCacheModel.canQuery) {
                                            showErrorToast(context, '查询过于频繁');
                                          } else {
                                            if (controller.text
                                                .trim()
                                                .isEmpty) {
                                              showMyToast('请输入合法订单号');
                                              return;
                                            }

                                            loginCacheModel.resetQuery();
                                            WkTools.query(
                                                context, controller.text);
                                          }
                                        },
                                        child: Text('查询')),
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
                Divider(),
//                ListTile(
//                  title: Text('分享 $appName'),
//                  subtitle: Text('向您的同学推荐 $appName'),
//                  trailing: Icon(Icons.arrow_right),
//                  leading: CircleAvatar(
//                    child: Icon(
//                      Icons.share,
//                      color: Colors.white,
//                    ),
//                    backgroundColor: Colors.lightBlueAccent,
//                  ),
//                  onTap: () {
//                    Share.share('安全稳定的网课解决方案——$appName\n$downloadUrl');
//                  },
//                ),
                StatefulBuilder(builder: (ctx, setS) {
                  return FutureBuilder<bool>(
                    builder: (ctx, data) {
                      var enableF = false;
                      if (data.hasData && data.data != null) {
                        enableF = data.data;
                      }

                      return SwitchListTile(
                        value: enableF,
                        onChanged: (val) async {
                          setS(() {});
                          enableF = val;
                          await SharedPreferenceUtil.setBool("startF", enableF);

                          if (enableF) {
                            await GlobalSettings.channel
                                .invokeMethod('enableForeground');
                          } else {
                            await GlobalSettings.channel
                                .invokeMethod('disableForeground');
                          }
                        },
                        secondary: CircleAvatar(
                          child: Icon(
                            Icons.notifications,
                            color: Colors.white,
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        title: Text('启动前台服务'),
                        subtitle: Text('使得 APP 及时接受消息'),
                      );
                    },
                    future: SharedPreferenceUtil.getBool("startF"),
                    initialData: false,
                  );
                }),
                Divider(),
                ListTile(
                  title: Text('查看更新记录'),
                  subtitle: Text('查看 $appName 每次更新的变动'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.history,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.brown,
                  ),
                  onTap: () {
                    UiTools.showChangelogDialog(context);
                  },
                ),
                ListTile(
                  title: Text('回到引导页'),
                  subtitle: Text('重新浏览 $appName 的引导页面'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.assignment,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.orange,
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return IntroScreen(
                        review: true,
                      );
                    }));
                  },
                ),
                ListTile(
                  title: Text('回到权限页'),
                  subtitle: Text('重新浏览 $appName 的授权页面'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.power,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.purple,
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return PermissionPage(
                        reView: true,
                      );
                    }));
                  },
                ),
                ListTile(
                  title: Text('联系我们'),
                  subtitle: Text('与 $appName 运营进行交流'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.mail,
                      color: Colors.white,
                    ),
                    foregroundColor: Colors.greenAccent,
                  ),
                  onTap: () async {
                    await launch(
                        'mailto:1461796308@qq.com?subject=ToolsPack&body=正文\n');
                  },
                ),
                ListTile(
                  title: Text('关于 $appName'),
                  subtitle: Text('打开关于页面'),
                  trailing: Icon(Icons.arrow_right),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.white,
                    ),
                    foregroundColor: Colors.teal,
                  ),
                  onTap: () async {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return AboutPageWk();
                    }));
                  },
                ),
              ]),
            ),
          ),
          UiTools.getBlurOverlay(context),
          Column(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).padding.top,
              ),
              Padding(
                padding: EdgeInsets.only(top: 8, right: 18, left: 18),
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
                            '设置页面',
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

  void unfocusAll() {
    myFocusNodeSchoolLogin.unfocus();
    myFocusNodeEmailLogin.unfocus();
    myFocusNodePasswordLogin.unfocus();
  }

  void _toggleLogin() {
    setState(() {
      _obscureTextLogin = !_obscureTextLogin;
    });
  }

  Future<void> gotoAgentPage() async {
    if (kReleaseMode) {
      if (accController.text.isEmpty || passController.text.isEmpty) {
        showMyToast('请输入合法信息');
        return;
      }
    }

    accN.unfocus();
    passN.unfocus();

    DialogUtil.showBlurDialog(context, (ctx) {
      return LoadingDialog(text: '正在获取数据...');
    });

    FullAgentData data;
    if (kReleaseMode) {
      data = await NetUtils4Wk.getAgentFullData(
          accController.text, passController.text);
    } else {
      data = await NetUtils4Wk.getAgentFullData('HYITshuake', 'nitamade');
    }
    Navigator.pop(context);

    if (data != null) {
      SharedPreferenceUtil.setString(SP_AGENTACC, accController.text);
      SharedPreferenceUtil.setString(SP_AGENTPASS, passController.text);

      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        return AgentPage(data);
      }));
    } else {
      showErrorToast(context, '登录失败');
    }
  }
}
