/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:shared/config/global_settings.dart';
import 'package:toolspack/pages/get_vpn_page.dart';
import 'package:toolspack/pages/paper_page.dart';
import 'package:toolspack/pages/web_page.dart';
import 'package:toolspack/pages/write_helper_page.dart';
import 'package:toolspack/utils/ui_tools.dart';
import 'package:toolspacklibs/utils/net_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class CiLi {
  String title;
  String url;

  CiLi(this.title, this.url);
}

class UesFulApps {
  String title;
  String size;
  String url;

  UesFulApps(this.title, this.size, this.url);
}

class HtmlAPack {
  String text;
  String url;

  HtmlAPack(this.text, this.url);

  @override
  String toString() {
    return '名称: $text';
  }
}

class ToolsPage extends StatefulWidget {
  static const routeName = "/ToolsPage";

  @override
  State<StatefulWidget> createState() {
    return _DebugPagePageState();
  }
}

class _DebugPagePageState extends State<ToolsPage> {
  final TextEditingController controller = TextEditingController();

  /// 磁力
  /// TODO: 使用动态获取
  final List<CiLi> ciliData = [
    CiLi('磁力吧', 'http://www.ciliba.best/s/%s.html'),
    CiLi('cabbage', 'https://zhima998.com/infolist.php?q=%s'),
  ];

  /// [https://mp.weixin.qq.com/s/zeq1sTmaPsKt7Bsok0Ldrg]
  /// TODO: 使用动态获取
  static final softwareListTitle = <String>[
    '①电脑办公',
    '②室内/外设计',
    '③平面设计',
    '④机械设计',
    '⑤影视动画',
    '⑥建筑设计',
    '⑦网页设计',
    '⑧屏幕录像',
    '⑨开发编程',
    '⑩电子绘图',
    '⑪数据分析',
    '⑫理科工具',
    '⑬虚拟机',
  ];

  static final String tempText = '';

  /// [https://www.lanzous.com/b79649/]
  Future<List<UesFulApps>> initUsefulAppData() async {
    final String sid = await rootBundle.loadString('assets/usefulApps.html');
    return await compute(runInitUsefulAppData, sid);
  }

  /// for [initUsefulAppData]
  static List<UesFulApps> runInitUsefulAppData(final String text) {
    final List<UesFulApps> usefulApps = [];
    dom.Document documentUsefulApps = parser.parse(text);
    documentUsefulApps.body.querySelectorAll('a').forEach((d) {
      if (d.className == 'mlink minPx-top') {
        var res = d.children;

        var title = res[1]
            .text
            .substring(0, res[1].text.indexOf(' '))
            .trim()
            .replaceAll('\n', '');
        var subTitle = res[1].children[0].text.trim().replaceAll('\n', '');

        usefulApps.add(UesFulApps(title, subTitle, d.attributes['href']));
      }
    });
    return usefulApps;
  }

  Future<Map<String, List<HtmlAPack>>> initSoftwareIndexData() async {
    final String sid = await rootBundle.loadString('assets/softwareIndex.html');
    return await compute(runInitSoftwareIndexData, sid);
  }

  /// for [initSoftwareIndexData]
  static Map<String, List<HtmlAPack>> runInitSoftwareIndexData(
      final String sid) {
    Map<String, List<HtmlAPack>> softwareIndexData = {};

    var links = <List<HtmlAPack>>[];

    dom.Document test11 = parser.parse(sid);

    test11.querySelector('div').children.forEach((n) {
      var tempList = <HtmlAPack>[];
      n.querySelectorAll('a').forEach((no) {
        tempList.add(HtmlAPack(no.text, no.attributes['href']));
//      printDebug4Wk(no.text);
      });
      links.add(tempList);
    });

    int i = -1;
    softwareListTitle.forEach((title) {
      ++i;
      softwareIndexData[title] = links[i];
    });

    return softwareIndexData;
  }

  /// [https://shimo.im/docs/uw1cmZ2xllsE7D8m/read]
  Future<Map<String, List<HtmlAPack>>> initDataBase() async {
    final String sid = await rootBundle.loadString('assets/database.html');
    return compute<String, Map<String, List<HtmlAPack>>>(runInitDataBase, sid);
  }

  /// for [initDataBase]
  static Map<String, List<HtmlAPack>> runInitDataBase(String sid) {
    Map<String, List<HtmlAPack>> fullData = {};
    var titles = <String>[];
    var links = <List<HtmlAPack>>[];

    var tempList = <HtmlAPack>[];

    dom.Document doc = parser.parse(sid);

    doc.getElementsByClassName('ql-editor')[0].children.forEach((n) {
      var list = n.querySelectorAll('a');
      if (list.length == 0) {
        titles.add(n.text.trim().replaceAll('\n', ''));
        if (tempList.length != 0) {
          links.add(tempList);
          // 更新
          tempList = <HtmlAPack>[];
        }
      } else {
        tempList.add(HtmlAPack(list[0].text, list[0].attributes['href']));
      }
    });

    links.add(tempList);

    int i = -1;
    titles.forEach((t) {
      ++i;
      fullData[t] = links[i];
    });

    return fullData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 100, bottom: 70),
              child: Column(children: <Widget>[
                ListTile(
                  enabled: true,
                  selected: true,
                  title: Text('DEBUG'),
                  leading: CircleAvatar(
                    child: Icon(Icons.bug_report),
                  ),
                  subtitle: Text('debug！'),
                  onTap: () async {
//                    if (remoteSocket.closeReason != null &&
//                        remoteSocket.closeCode != null &&
//                        remoteSocket.readyState != 1) {
//                      await initSocket();
//                    }
//
//                    var orderCode = NetUtils4Wk.makeOrderText();
//
//                    remoteSocket.add(NetUtils4Wk.makeOrderText());
//                    DialogUtil.showBlurDialog(context, (context) {
//                      return AlertDialog(
//                        title: Text('团购二维码'),
//                        content: SingleChildScrollView(
//                          child: Column(
//                            children: [
//                              SizedBox(
//                                child: QrImage(
//                                  data: orderCode,
//                                  version: QrVersions.auto,
//                                  size: 200.0,
//                                ),
//                                height: 200,
//                                width: 200,
//                              ),
//                              const SizedBox(
//                                height: 10,
//                              ),
//                              const Text('用手机扫描此二维码加入团购\n'
//                                  '注意事项:\n'
//                                  '①仅限相同特征码用户参与！\n'
//                                  '②每个团购二维码有效期为10分钟，过期后需要重新下单。\n'
//                                  '③目前团购不支持与优惠券叠加使用\n'
//                                  '⑤团购人员最大3人')
//                            ],
//                          ),
//                        ),
//                        actions: [DialogUtil.getDialogCloseButton(context)],
//                      );
//                    });
                  },
                  trailing: Icon(Icons.arrow_right),
                ),
                ListTile(
                  title: Text('论文小助手'),
                  leading: CircleAvatar(
                    child: Icon(Icons.assignment),
                  ),
                  subtitle: Text('懒的去找论文，就来试试它！'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return PaperPage();
                    }));
                  },
                  trailing: Icon(Icons.arrow_right),
                ),
                ListTile(
                  title: const Text('写作助手'),
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(
                      Icons.text_fields,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: const Text('支持同义转换文章，AI重写文章等功能！'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return WriteHelperPage();
                    }));
                  },
                  trailing: Icon(Icons.arrow_right),
                ),
                Divider(),
                ListTile(
                  title: Text('1分钱/天迅雷会员'),
                  leading: CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text('一分钱一天'),
                  onTap: () async {
                    DialogUtil.showBlurDialog(
                        context, (context) => LoadingDialog(text: '正在获取...'));
                    final url = await NetUtils4Wk.getThunderUrl();
                    Navigator.pop(context);
                    Clipboard.setData(ClipboardData(text: url));
                    showMyToast('已复制，请在搜索框内粘贴。');
                    GlobalSettings.channel.invokeMethod('gotoTaoBao');
                  },
                  trailing: Icon(Icons.arrow_right),
                ),
                ListTile(
                  title: Text('科学上网'),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(
                      Icons.flash_on,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Text('GET FREE SSR/V2RAY'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return GetVPNPage();
                    }));
                  },
                  trailing: Icon(Icons.arrow_right),
                ),
                Divider(),
                buildFilmSearchTile(),
                buildCiLiSearchTile(),
                buildUsefulAppsTile(),
                buildSoftwareIndexTile(),
                buildDataBase(),
                Divider(),
                ListTile(
                  enabled: false,
                  title: Text('官方论坛'),
                  leading: CircleAvatar(
                    child: Icon(Icons.forum),
                  ),
                  subtitle: const Text('URL_HERE'),
                  trailing: const Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) {
                      return WebPage(
                        title: '论坛',
                        url: 'https://forum.geek-cloud.top/',
                      );
                    }));
                  },
                ),
                Divider(),
                ListTile(
                  title: Text('虚拟商城'),
                  leading: CircleAvatar(
                    child: Icon(
                      Icons.attach_money,
                      color: Colors.white,
                    ),
                    backgroundColor: Colors.black,
                  ),
                  subtitle: Text('刷赞、空间、代练。'),
                  onTap: () {
                    launch('http://lts.ds919.cn/');
                  },
                  trailing: Icon(Icons.arrow_right),
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
                            '工具页面',
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

  getListAlertDialog(final String title, final Widget view) {
    return AlertDialog(
      title: Text(title),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        child: view,
      ),
      actions: <Widget>[DialogUtil.getDialogCloseButton(context)],
    );
  }

  buildUsefulAppsTile() {
    return FutureBuilder<List<UesFulApps>>(
      builder: (ctx, data) {
//        if (!data.hasData || data.data == null) {
//          return Container();
//        }
        return ListTile(
          title: Text('常用 APP'),
//                  children: tiles,
          subtitle: Text('https://www.lanzous.com/b79649/'),
          trailing: Icon(Icons.arrow_right),
          leading: CircleAvatar(
            child: Icon(
              Icons.apps,
              color: Colors.white,
            ),
            backgroundColor: Colors.pinkAccent,
          ),
          onTap: () {
            DialogUtil.showBlurDialog(context, (ctx) {
              final view = ListView.separated(
                itemBuilder: (ctx, index) {
                  final app = data.data[index];
                  final ts = TextStyle(color: Colors.white);
                  return ListTile(
                    title: Text(app.title),
                    subtitle: Text(app.size),
                    leading: CircleAvatar(
                      child: Text(
                        app.title.substring(0, 1),
                        style: ts,
                      ),
                      backgroundColor: Colors.pinkAccent,
                    ),
                    onTap: () {
                      launch('https://www.lanzous.com${app.url}');
                    },
                  );
                },
                itemCount: data.data.length,
                physics: BouncingScrollPhysics(),
                separatorBuilder: (ctx, index) {
                  return Divider();
                },
              );
              return getListAlertDialog('常用 APP 列表', view);
            });
          },
        );
      },
      future: initUsefulAppData(),
    );
  }

  buildCiLiSearchTile() {
    return ExpansionTile(
      title: Text('磁力搜索'),
      subtitle: Text('( •̀ ω •́ )y'),
      leading: CircleAvatar(
        child: Icon(
          Icons.beenhere,
          color: Colors.white,
        ),
        backgroundColor: Colors.orange,
      ),
      children: List<Widget>.generate(ciliData.length, (index) {
        var cd = ciliData[index];
        return ListTile(
          title: Text(cd.title),
          subtitle: Text('${cd.url.replaceAll('%s', appName)}'),
          leading: CircleAvatar(
            child: Text(
              index.toString(),
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
          ),
          trailing: Icon(Icons.arrow_right),
          onTap: () {
            DialogUtil.showBlurDialog(context, (ctx) {
              return AlertDialog(
                title: Text('磁力搜索'),
                content: TextField(
                  controller: controller,
                  decoration: InputDecoration(hintText: '输入信息'),
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () async {
                        if (controller.text == null ||
                            controller.text.trim() == '') {
                          showErrorToast(context, '请输入合法关键词');
                        } else {
                          launch('${cd.url.replaceAll('%s', controller.text)}');
                        }
                      },
                      child: Text('搜索')),
                  DialogUtil.getDialogCloseButton(context)
                ],
              );
            });
          },
        );
      }),
    );
  }

  buildFilmSearchTile() {
    return ListTile(
      title: Text('电影搜索'),
      subtitle: Text('http://pianyuan.la/'),
      trailing: Icon(Icons.arrow_right),
      leading: CircleAvatar(
        child: Icon(
          Icons.personal_video,
          color: Colors.white,
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      onTap: () {
        DialogUtil.showBlurDialog(context, (ctx) {
          return AlertDialog(
            title: Text('电影搜索'),
            content: TextField(
              controller: controller,
              decoration: InputDecoration(hintText: '输入电影名称'),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () async {
                    if (controller.text == null ||
                        controller.text.trim() == '') {
                      showErrorToast(context, '请输入合法关键词');
                    } else {
                      launch('http://pianyuan.la/search?q=${controller.text}');
                    }
                  },
                  child: Text('搜索')),
              DialogUtil.getDialogCloseButton(context)
            ],
          );
        });
      },
    );
  }

  buildSoftwareIndexTile() {
    return FutureBuilder<Map<String, List<HtmlAPack>>>(
      builder: (ctx, data) {
//        if (!data.hasData || data.data == null) {
//          return Container();
//        }
        return ExpansionTile(
          title: Text('软件目录'),
          subtitle: Text('软件安装包、教程'),
          leading: CircleAvatar(
            child: Icon(
              Icons.list,
              color: Colors.white,
            ),
            backgroundColor: Colors.brown,
          ),
          children: List<Widget>.generate(softwareListTitle.length, (index) {
            var title = softwareListTitle[index].substring(1);
            return ListTile(
              title: Text(title),
              leading: CircleAvatar(
                child: Text(
                  softwareListTitle[index].substring(0, 1),
                ),
                backgroundColor: Colors.brown,
              ),
              onTap: () {
                if (!data.hasData) {
                  showErrorToast(context, '数据加载中...');
                  return;
                }

                // 获取 <a href> 数据列表
                var htmlPackData = data.data[softwareListTitle[index]];

                if (htmlPackData == null) return;

                DialogUtil.showBlurDialog(context, (ctx) {
                  final view = ListView.separated(
                    itemBuilder: (ctx, index) {
                      final obj = htmlPackData[index];
                      final ts = TextStyle(color: Colors.white);
                      return ListTile(
                        title: Text(obj.text),
                        leading: CircleAvatar(
                          child: Text(
                            obj.text.substring(0, 1),
                            style: ts,
                          ),
                          backgroundColor: Colors.brown,
                        ),
                        onTap: () {
                          launch(obj.url);
                        },
                      );
                    },
                    itemCount: htmlPackData.length,
                    physics: BouncingScrollPhysics(),
                    separatorBuilder: (ctx, index) {
                      return Divider();
                    },
                    shrinkWrap: true,
                  );
                  return getListAlertDialog(title, view);
                });
              },
            );
          }),
        );
      },
      future: initSoftwareIndexData(),
    );
  }

  buildDataBase() {
    return FutureBuilder<Map<String, List<HtmlAPack>>>(
      builder: (ctx, data) {
//        if (!data.hasData || data.data == null) {
//          printDebug4Wk('buildDataBase NULL');
//          return Container();
//        }
//        printDebug4Wk('buildDataBase NOT NULL');

        var tiles = <Widget>[];

        if (data.hasData) {
          var i = 0;
          data.data.keys.forEach((t) {
            ++i;
            var tempTiles = <Widget>[];
            var link = data.data[t];

            link.forEach((pack) {
              tempTiles.add(ListTile(
                title: Text(pack.text),
                onTap: () {
                  launch(pack.url);
                },
                trailing: Icon(Icons.arrow_right),
              ));
            });

            tiles.add(ExpansionTile(
              title: Text(t),
              leading: CircleAvatar(
                child: Text(
                  i.toString(),
                ),
                backgroundColor: Colors.lightGreen,
              ),
              children: tempTiles,
            ));
          });
        }

        return ExpansionTile(
          title: Text('资料库'),
          subtitle: Text('https://shimo.im/docs/uw1cmZ2xllsE7D8m/read'),
          leading: CircleAvatar(
            child: Icon(
              Icons.data_usage,
              color: Colors.white,
            ),
            backgroundColor: Colors.lightGreen,
          ),
          children: tiles,
        );
      },
      future: initDataBase(),
    );
  }

//  loadData() async {
//    ReceivePort receivePort = ReceivePort();
//    await Isolate.spawn(dataLoader, receivePort.sendPort);
//
//    SendPort sendPort = await receivePort.first;
//
//    ReceivePort response = ReceivePort();
//
//    sendPort.send(['https://www.jianshu.com/p/87810f85595c', response.sendPort]);
//
//    var msg = await response.first;
//
//    print(msg);
//  }

}

//dataLoader(SendPort sendPort) async {
//  ReceivePort port = ReceivePort();
//  sendPort.send(port.sendPort);
//  await for (var msg in port){
//    String data = msg[0];
//    SendPort replyTo = msg[1];
//
//    String dataURL = data;
//    var result = await Dio().get(data);
//    replyTo.send(result.data);
//  }
//}
