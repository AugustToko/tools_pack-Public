/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:taobaoke_shared/rep/wp_rep.dart';
import 'package:taobaoke_shared/widget/wtb_shop_mt_widget.dart';
import 'package:toolspack/design_course/design_course_app_theme.dart';
import 'package:toolspack/pages/home_design_course.dart';
import 'package:toolspack/pages/settings_page.dart';
import 'package:toolspack/pages/tbk_item_search_page.dart';
import 'package:toolspack/pages/tools_page.dart';
import 'package:toolspack/widgets/navbar/navbar.dart';
import 'package:toolspacklibs/utils/net_utils.dart';

import '../main.dart';

/// [MainPage]
/// 仅带有一个 BottomNavigationBar
class MainPage extends StatefulWidget {
  final FocusNode _blankFocusNode = FocusNode();

  final taps = [
    Tab(text: '猜你喜欢'),
    Tab(text: '数码家电'),
    Tab(text: '女装'),
    Tab(text: '男装'),
//              Tab(text: '食品'),
  ];

  @override
  State<StatefulWidget> createState() {
    return _IndexState();
  }
}

class _IndexState extends State<MainPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  List<NavBarItemData> _navBarItems;

  int _selectedNavIndex = 0;

  List<Widget> _viewsByIndex;

  TabController _controller;

  buildAppBar() {
    return SliverAppBar(
      elevation: 0,
      title: getSearchBarUI(padding: 0, height: 40),
      pinned: true,
      floating: true,
    );
  }

  buildAppBarHeader() {
    return SliverPersistentHeader(
      delegate: _SliverAppBarDelegate(
        TabBar(
          labelStyle: TextStyle(fontWeight: FontWeight.w600),
          labelColor: Colors.deepOrange,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepOrange,
          tabs: widget.taps,
          controller: _controller,
        ),
      ),
      pinned: true,
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[buildAppBar(), buildAppBarHeader()];
  }

  buildShop() {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GestureDetector(
              child: Scaffold(
                body: NestedScrollView(
                  headerSliverBuilder: _sliverBuilder,
                  body: TabBarView(
                    controller: _controller,
                    physics: BouncingScrollPhysics(),
                    children: <Widget>[
                      MtList(TbkMtRep('6708', oaid: OAID)),
                      MtList(TbkMtRep('3759', oaid: OAID)),
                      MtList(TbkMtRep('3767', oaid: OAID)),
                      MtList(TbkMtRep('3764', oaid: OAID)),
                    ],
                  ),
                ),
              ),
              onTap: () {
                FocusScope.of(context).requestFocus(widget._blankFocusNode);
              })
        ],
      ),
    );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this); // 注册监听器
    super.initState();
    _controller =
        TabController(length: widget.taps.length, vsync: this, initialIndex: 0);

    NetUtils4Wk.sendEnterAppData();

    _navBarItems = [
      NavBarItemData("首页", OMIcons.home, 110, Color(0xff01b87d)),
      NavBarItemData("工具", OMIcons.widgets, 110, Color(0xff594ccf)),
      if (!kIsWeb) NavBarItemData("查券", OMIcons.shop, 115, Color(0xff09a8d9)),
      NavBarItemData("设置", OMIcons.settings, 105, Color(0xfff2873f)),
    ];

    _viewsByIndex = <Widget>[
      DesignCourseHomeScreen(),
      ToolsPage(),
      SettingsPage(),
    ];

    if (!kIsWeb) _viewsByIndex.insert(2, buildShop());

    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // 移除监听器
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {}
  }

  @override
  Widget build(BuildContext context) {
    var contentView =
        _viewsByIndex[min(_selectedNavIndex, _viewsByIndex.length - 1)];

    return WillPopScope(
      child: Scaffold(
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              width: double.infinity,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: contentView,
              ),
            ),
            NavBar(
              items: _navBarItems,
              itemTapped: _handleNavBtnTapped,
              currentIndex: _selectedNavIndex,
            )
          ],
        ),
      ),
      onWillPop: () {
        FocusScope.of(context).unfocus();
        return DialogUtil.showQuitDialog(context, blurBG: true);
      },
    );
  }

  void _handleNavBtnTapped(int index) {
    setState(() {
      _selectedNavIndex = index;
    });
  }

  Widget getSearchBarUI({double padding = 16, double height = 50}) {
    var controller = TextEditingController();
    return Padding(
      padding: EdgeInsets.only(
          top: padding, bottom: padding, right: padding, left: padding),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: HexColor('#F8FAFB'),
          borderRadius: const BorderRadius.only(
            bottomRight: Radius.circular(13.0),
            bottomLeft: Radius.circular(13.0),
            topLeft: Radius.circular(13.0),
            topRight: Radius.circular(13.0),
          ),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 16),
                child: TextFormField(
                  controller: controller,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: DesignCourseAppTheme.nearlyBlue,
                  ),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "商品搜索",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: HexColor('#B9BABC'),
                    ),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      letterSpacing: 0.2,
                      color: HexColor('#B9BABC'),
                    ),
                  ),
                  onEditingComplete: () {
                    if (controller.text.isEmpty) {
                      showErrorToast(context, '请输入合法关键词');
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => TbkSearchPage(
                            keyWord: controller.text,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            SizedBox(
              width: 60,
              height: 60,
              child: Icon(Icons.search, color: HexColor('#B9BABC')),
            )
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: _tabBar,
      color: Theme.of(context).scaffoldBackgroundColor,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
