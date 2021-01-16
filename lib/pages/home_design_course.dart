/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/drink_card/drink_card.dart';
import 'package:lingyun_widget/loading_dialog.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:provider/provider.dart';
import 'package:toolspack/pages/ordercheck_page.dart';
import 'package:toolspack/utils/shared_prefs.dart';
import 'package:toolspack/widgets/banner/flutter_banner_swiper.dart';
import 'package:toolspack/widgets/glass_view.dart';
import 'package:toolspack_shared/model/groceries.dart';
import 'package:toolspack_shared/model/pack_data.dart';
import 'package:toolspack_shared/model/payInfo.dart';
import 'package:toolspack_shared/model/student_info.dart';
import 'package:toolspacklibs/model/error_msg.dart';
import 'package:toolspacklibs/model/login_cache.dart';
import 'package:toolspacklibs/utils/net_utils.dart';
import 'package:toolspacklibs/utils/wk_tools.dart';
import 'package:url_launcher/url_launcher.dart';

import '../design_course/design_course_app_theme.dart';
import '../main.dart';
import '../utils/ui_tools.dart';

class DesignCourseHomeScreen extends StatefulWidget {
  @override
  _DesignCourseHomeScreenState createState() => _DesignCourseHomeScreenState();
}

class _DesignCourseHomeScreenState extends State<DesignCourseHomeScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  BtnTextTupe categoryType = BtnTextTupe.cheap;

//  static MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//    keywords: <String>['flutterio', 'beautiful apps'],
//    contentUrl: 'https://flutter.cn',
////    birthday: DateTime.now(),
//    childDirected: false,
////    designedForFamilies: false,
////    gender: MobileAdGender.male, // or MobileAdGender.female, MobileAdGender.unknown
//    testDevices: <String>[], // Android emulators are considered test devices
//  );
//
//  BannerAd myBanner = BannerAd(
//    // Replace the testAdUnitId with an ad unit id from the AdMob dash.
//    // https://developers.google.com/admob/android/test-ads
//    // https://developers.google.com/admob/ios/test-ads
//    adUnitId: BannerAd.testAdUnitId,
//    size: AdSize.smartBanner,
//    targetingInfo: targetingInfo,
//    listener: (MobileAdEvent event) {
//      print("BannerAd event is $event");
//    },
//  );

  AnimationController pageAniController;
  Animation pageAnimation;

  AnimationController fabAniController;
  Animation fabScaleAnimation;

  final FocusNode blankFocusNode = FocusNode();

  @override
  void initState() {
    pageAniController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    pageAnimation = Tween<double>(begin: 0.0, end: 0.9).animate(CurvedAnimation(
        parent: pageAniController,
        curve: Interval(0, 0.9, curve: Curves.fastOutSlowIn)));

    fabAniController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    fabScaleAnimation = Tween<double>(begin: 0.0, end: 1).animate(
        CurvedAnimation(
            parent: fabAniController,
            curve: Interval(0, 1, curve: Curves.fastOutSlowIn)));

    super.initState();
//    myBanner
//      // typically this happens well before the ad is shown
//      ..load()
//      ..show(
//        // Positions the banner ad 60 pixels from the bottom of the screen
//        anchorOffset: 60.0,
//        // Positions the banner ad 10 pixels from the center of the screen to the right
//        horizontalCenterOffset: 0.0,
//        // Banner Position
//        anchorType: AnchorType.bottom,
//      );
  }

  @override
  void dispose() {
    pageAniController.dispose();
    fabAniController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    pageAniController.forward();
    return GestureDetector(
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 100,
                  ),
                  getSearchBarUI(),
                  buildBannerSwipe(),
                  getNoticeUI(),
                  getSpCategoryUI(),
                  const SizedBox(
                    height: 15,
                  ),
                  getUserCourseUI(),
                  const SizedBox(height: 70)
                ],
              ),
            ),
            UiTools.getBlurOverlay(context),
            getAppBarUI(),
          ],
        ),
        floatingActionButton: Consumer<LoginCacheModel>(
          builder: (context, data, child) {
            if (data.checkedCourses != 0 && fabScaleAnimation.value == 0)
              fabAniController.forward();

            if (data.checkedCourses == 0 && fabScaleAnimation.value != 0)
              fabAniController.reverse();

            return Padding(
              padding: EdgeInsets.only(
                bottom: 64,
              ),
              child: AnimatedBuilder(
                  animation: fabAniController,
                  builder: (ctx, child) {
                    return Container(
                      height: fabScaleAnimation.value * 55,
                      width: fabScaleAnimation.value * 55,
                      child: Stack(
                        children: <Widget>[
                          FloatingActionButton(
                            elevation: 0,
                            onPressed: () {
                              if (data.checkedCourses > 0) {
                                openPayView(context);
                              }
                            },
                            focusElevation: 15,
                            child: Icon(Icons.shopping_cart),
                            tooltip: '购物车',
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: CircleAvatar(
                              backgroundColor: Colors.redAccent,
                              child: Center(
                                child: StatefulBuilder(builder: (ctx, update) {
                                  return Text(
                                    data.checkedCourses.toString(),
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  );
                                }),
                              ),
                              radius: 8,
                            ),
                          )
                        ],
                      ),
                    );
                  }),
            );
          },
        ),
      ),
      onTap: () {
        // 取消焦点
        FocusScope.of(context).requestFocus(blankFocusNode);
      },
    );
  }

  Consumer<LoginCacheModel> buildBannerSwipe() {
    return Consumer<LoginCacheModel>(builder: (ctx, data, child) {
      if (data == null ||
          data.packData == null ||
          data.packData.banners == null ||
          data.packData.banners.length == 0) {
        return const SizedBox();
      }

      return Column(
        children: <Widget>[
          MyBannerSwiper(
            showIndicator: true,
            //width  和 height 是图片的高宽比  不用传具体的高宽   必传
            height: 100,
            width: 42,
            //轮播图数目 必传
            length: data.packData.banners.length,
            //轮播的item  widget 必传
            getwidget: (index) {
              var banner =
                  data.packData.banners[index % data.packData.banners.length];
              return GestureDetector(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                  child: Material(
                    elevation: 0,
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Stack(
                        children: <Widget>[
                          FadeInImage.assetNetwork(
                            placeholder: 'assets/images/logo.png',
                            image: banner.assetUrl,
                            width: 400,
                            fit: BoxFit.cover,
                          ),
                          Container(
                            color: Theme.of(context)
                                .scaffoldBackgroundColor
                                .withOpacity(0.5),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  banner.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    letterSpacing: 0.27,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  banner.subTitle,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                  ),
                                ),
//                          SizedBox(
//                            height: 8,
//                          ),
//                          Text(
//                            bannerData.messageText,
//                            style: TextStyle(color: Colors.white, fontSize: 15),
//                          ),
                                const SizedBox(
                                  height: 8,
                                ),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                      side: BorderSide(
                                        width: 1.5,
                                      )),
                                  onPressed: () {
                                    checkBannerBtn(ctx, banner);
                                  },
                                  child: Text(
                                    "了解更多",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      );
    });
  }

  /// 公告
  Widget getNoticeUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
          child: Text(
            '通知',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.27,
            ),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  getButtonUI(BtnTextTupe.cheap, false),
                  const SizedBox(width: 16),
                  getButtonUI(BtnTextTupe.safe, false),
                  const SizedBox(width: 16),
                  getButtonUI(BtnTextTupe.fast, false),
                ],
              ),
              const SizedBox(height: 12),
              Consumer<LoginCacheModel>(
                builder: (ctx, data, child) {
                  final widgets = <Widget>[];
                  widgets.add(
                    DrinkListCard(
                      bgColor: Theme.of(context).backgroundColor,
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.notifications,
                          color: Colors.white,
                        ),
                        radius: 20,
                      ),
                      title: Text(
                        '系统公告',
                        style: Styles.text(18, true),
                      ),
                      trailing: Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                      contentTitle: '${data.hitokoto}',
                      contentBody: '${data.packData.notice}',
                    ),
                  );
                  if (data.packData.agentModel.notice.trim() != '' &&
                      data.packData.agentModel.notice != '无' &&
                      data.packData.agentModel.notice != 'NULL') {
                    widgets.add(
                      GlassView(
                        animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                                parent: pageAniController,
                                curve: Interval(0, 1.0,
                                    curve: Curves.fastOutSlowIn))),
                        animationController: pageAniController,
                        text: '${data.packData.agentModel.notice}',
                        showIcon: false,
                      ),
                    );
                    widgets.add(
                      const SizedBox(
                        height: 12,
                      ),
                    );
                  }

                  return Column(
                    children: widgets,
                  );
//                  return GlassView(
//                    animation: Tween<double>(begin: 0.0, end: 1.0).animate(
//                        CurvedAnimation(
//                            parent: pageAniController,
//                            curve:
//                                Interval(0, 1.0, curve: Curves.fastOutSlowIn))),
//                    animationController: pageAniController,
//                    text: '${data.hitokoto}\n\n${data.packData.notice}',
//                  );
                },
              ),
            ],
          ),
        ),

//        CategoryListView(
//          callBack: (c) {
//            final loginCacheModel =
//            Provider.of<LoginCacheModel>(context, listen: false);
//
//            if (loginCacheModel.currentStudentInfo == null) {
//              gotoLoginPage(context);
//            } else {
//              Navigator.push<dynamic>(
//                context,
//                MaterialPageRoute<dynamic>(
//                  builder: (BuildContext context) => CourseInfoScreen(c),
//                ),
//              );
//            }
//          },
//        ),
      ],
    );
  }

  Widget getButtonUI(final BtnTextTupe categoryTypeData, bool isSelected) {
    String txt = '';
    if (BtnTextTupe.cheap == categoryTypeData) {
      txt = '便宜';
    } else if (BtnTextTupe.fast == categoryTypeData) {
      txt = '快速';
    } else if (BtnTextTupe.safe == categoryTypeData) {
      txt = '安全';
    }
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            border: Border.all(color: DesignCourseAppTheme.nearlyBlue)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: Colors.white24,
            borderRadius: const BorderRadius.all(Radius.circular(24.0)),
            onTap: () {
//              setState(() {
//                categoryType = categoryTypeData;
//              });
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 12, bottom: 12, left: 18, right: 18),
              child: Center(
                child: Text(
                  txt,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.27,
                    color: isSelected
                        ? DesignCourseAppTheme.nearlyWhite
                        : DesignCourseAppTheme.nearlyBlue,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getSearchBarUI() {
    var controller = TextEditingController();
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AnimatedBuilder(
              animation: pageAniController,
              builder: (ctx, child) {
                return Container(
                  width:
                      MediaQuery.of(context).size.width * pageAnimation.value,
                  height: 64,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
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
                                  fontFamily: 'WorkSans',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                keyboardType: TextInputType.text,
                                decoration: InputDecoration(
                                  hintText: "百度搜索",
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
                                  launch(
                                      'https://www.baidu.com/s?ie=UTF-8&wd=${controller.text}');
                                  showMyToast('${controller.text}');
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            height: 60,
                            child:
                                Icon(Icons.search, color: HexColor('#B9BABC')),
                          )
                        ],
                      ),
                    ),
                  ),
                );
              })
//          const Expanded(
//            child: const SizedBox(),
//          )
        ],
      ),
    );
  }

  Consumer<LoginCacheModel> getUserCourseUI() {
    return Consumer<LoginCacheModel>(
      builder: (ctx, cacheData, child) {
        Widget childWidget;
        if (cacheData.studentLoginList.length == 0) {
          childWidget = buildLoginButton();
        } else {
          childWidget = Column(
            children: List<Widget>.generate(cacheData.studentLoginList.length,
                (index) {
              final studentInfoU = cacheData.studentLoginList[index];

              return ExpansionTile(
                title: Text(
                  '我的${studentInfoU.obj.platformType.name}课程',
                  textAlign: TextAlign.left,
                ),
                subtitle: Text('${studentInfoU.obj.courseList.length} 门课'),
                leading: CircleAvatar(
                  child: Text(studentInfoU.obj.platformType.name[0]),
                ),
                children: List<Widget>.generate(
                    studentInfoU.obj.courseList.length, (index) {
                  final courseData = studentInfoU.obj.courseList[index];
                  final targetStuObj = studentInfoU.obj;
                  return Column(
                    children: <Widget>[
                      CheckboxListTile(
                        title: Text(courseData.courseName),
                        value:
                            targetStuObj.checkedCourseList.contains(courseData),
                        onChanged: (val) {
                          if (val &&
                              !targetStuObj.checkedCourseList
                                  .contains(courseData)) {
                            targetStuObj.checkedCourseList.add(courseData);
                            cacheData.checkCourse();
                          } else {
                            targetStuObj.checkedCourseList.remove(courseData);
                            cacheData.uncheckCourse();
                          }
                        },
                        secondary: CircleAvatar(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                          backgroundColor: Colors.lightBlueAccent,
                        ),
                        subtitle: Text('章节数量: ${courseData.chapterCount}'),
//                  trailing: Icon(Icons.keyboard_arrow_right),
//                  onTap: () async {
//                    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Test')));
//                  },
//                  onLongPress: (){
//                    openPayView(context, courseData);
//                  },
                      ),
                      Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Colors.black.withOpacity(0.05),
                      )
                    ],
                  );
                }),
              );
            }),
          );
        }

        // OLD STYLE
//        childWidget = Column(
//          mainAxisAlignment: MainAxisAlignment.center,
//          crossAxisAlignment: CrossAxisAlignment.start,
//          children: <Widget>[
//            Text(
//              '我的${studentInfoU.obj.platformType.name}课程 （${studentInfoU.obj.courseList.length} 门）',
//              textAlign: TextAlign.left,
//              style: TextStyle(
//                fontWeight: FontWeight.w600,
//                fontSize: 22,
//                letterSpacing: 0.27,
//                color: DesignCourseAppTheme.darkerText,
//              ),
//            ),
//            SizedBox(
//              height: 18,
//            ),
//            Column(
//              children: List<Widget>.generate(
//                  studentInfoU.obj.courseList.length, (index) {
//                final courseData = studentInfoU.obj.courseList[index];
//                final targetStuObj = studentInfoU.obj;
//                return Column(
//                  children: <Widget>[
//                    CheckboxListTile(
//                      title: Text(courseData.courseName),
//                      value: targetStuObj.checkedCourseList
//                          .contains(courseData),
//                      onChanged: (val) {
//                        if (val &&
//                            !targetStuObj.checkedCourseList
//                                .contains(courseData)) {
//                          targetStuObj.checkedCourseList.add(courseData);
//                          cacheData.checkCourse();
//                        } else {
//                          targetStuObj.checkedCourseList
//                              .remove(courseData);
//                          cacheData.uncheckCourse();
//                        }
//                      },
//                      secondary: CircleAvatar(
//                        child: Text(
//                          '${index + 1}',
//                          style: TextStyle(
//                              fontSize: 18, color: Colors.white),
//                        ),
//                        backgroundColor: Colors.lightBlueAccent,
//                      ),
//                      subtitle: Text('章节数量: ${courseData.chapterCount}'),
////                  trailing: Icon(Icons.keyboard_arrow_right),
////                  onTap: () async {
////                    Scaffold.of(context).showSnackBar(SnackBar(content: Text('Test')));
////                  },
////                  onLongPress: (){
////                    openPayView(context, courseData);
////                  },
//                    ),
//                    Divider(
//                      thickness: 1,
//                      indent: 20,
//                      endIndent: 20,
//                      color: Colors.black.withOpacity(0.05),
//                    )
//                  ],
//                );
//              }),
//            ),
//            const SizedBox(
//              height: 20,
//            )
//          ],
//        );

        Widget widget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '我的课程',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 22,
                letterSpacing: 0.27,
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            childWidget
          ],
        );

        return Padding(
          padding: const EdgeInsets.only(top: 4, right: 16, left: 16),
          child: Column(
            children: <Widget>[widget],
          ),
        );
      },
    );
  }

  Consumer<LoginCacheModel> getAppBarUI() {
    return Consumer<LoginCacheModel>(
      builder: (ctx, final LoginCacheModel cacheData, child) {
        VoidCallback function = cacheData.currentStudentInfo == null
            ? () {
                FocusScope.of(context).requestFocus(blankFocusNode);
                gotoLoginPage(ctx);
              }
            : () {
                FocusScope.of(context).requestFocus(blankFocusNode);
                UiTools.showMyMsgDialog(context, loginCache);
              };

        return Container(
          padding: EdgeInsets.only(
              top: 8.0 + MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
              bottom: 16),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '选择你的',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    Text(
                      '解决方案',
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
              FlatButton(
                onPressed: function,
                child: Text(
                  cacheData.currentStudentInfo == null ? '登录' : '我的信息',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    letterSpacing: 0.27,
                    color: DesignCourseAppTheme.nearlyBlue,
                  ),
                ),
              ),
              const SizedBox(width: 20),
            ],
          ),
        );
      },
    );
  }

  /// 专区
  Widget getSpCategoryUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 18, right: 16),
          child: Text(
            '专区',
            textAlign: TextAlign.left,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 22,
              letterSpacing: 0.27,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // U校园测验/考试 为硬编码
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            children: <Widget>[
              buildUschool(),
            ],
          ),
        ),
        // const SizedBox(height: 16),
        // CategoryListView(
        //   callBack: (c) {
        //     final loginCacheModel =
        //         Provider.of<LoginCacheModel>(context, listen: false);
        //
        //     if (loginCacheModel.currentStudentInfo == null) {
        //       gotoLoginPage(context);
        //     } else {
        //       Navigator.push<dynamic>(
        //         context,
        //         MaterialPageRoute<dynamic>(
        //           builder: (BuildContext context) => CourseInfoScreen(c),
        //         ),
        //       );
        //     }
        //   },
        // ),
      ],
    );
  }

  // Future<void> subJSMN(
  //     ctx, Function(String orderText, String spcode) after) async {
  //   final loginCacheModel =
  //       Provider.of<LoginCacheModel>(context, listen: false);
  //
  //   if (loginCacheModel.spcode == null ||
  //       loginCacheModel.spcode.trim().isEmpty) {
  //     return null;
  //   }
  //
  //   DialogUtil.showBlurDialog(context, (ctx) {
  //     return LoadingDialog(text: '正在发送数据...');
  //   });
  //
  //   final orderText = NetUtils4Wk.makeOrderText();
  //
  //   final aliResult =
  //       await NetUtils4Wk.sendOtherData(orderText, loginCacheModel.spcode);
  //
  //   NetUtils4Wk.gotoAliPay(context, aliResult, onError: (errorType) {
  //     switch (errorType) {
  //       case TPErrorType.NetWorkError:
  //         showErrorToast(ctx, '服务器验证失败!');
  //         break;
  //       case TPErrorType.ParamError:
  //         showErrorToast(ctx, '数据出现错误!');
  //         break;
  //       default:
  //         break;
  //     }
  //   });
  //
  //   Navigator.pop(context);
  //
  //   await showCheckPayDialog(ctx, orderText, () async {
  //     showMyToast('成功');
  //     after(orderText, loginCacheModel.spcode);
  //     return true;
  //   });
  // }

  void showUTestDialog() {
    DialogUtil.showBlurDialog(context, (ctx) {
      final accountController = TextEditingController();
      final passwordController = TextEditingController();
      final remarksController = TextEditingController();

      return AlertDialog(
        title: Text('第九届大学生安全知识竞赛'),
        content: Wrap(
          children: <Widget>[
            Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(hintText: '账号'),
                  controller: accountController,
                ),
                const SizedBox(
                  height: 16,
                ),
                TextField(
                  decoration: InputDecoration(hintText: '密码'),
                  controller: passwordController,
                ),
                const SizedBox(height: 16),
//                              Row(
//                                children: <Widget>[
//                                  FlatButton(
//                                      onPressed: () async {
//
//                                      },
//                                      child: Text(
//                                        '测试登录',
//                                        style: TextStyle(color: Colors.blue),
//                                      ))
//                                ],
//                              ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(hintText: '备注内容'),
                  maxLines: 2,
                  controller: remarksController,
                ),
                const SizedBox(height: 16),
                Text('请务必确保账号、密码正确！')
              ],
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
            )
          ],
        ),
        actions: <Widget>[
          FlatButton(
              onPressed: () {
                submitUnitTask(ctx, accountController.text,
                    passwordController.text, remarksController.text);
              },
              child: Text('提交')),
          DialogUtil.getDialogCloseButton(context)
        ],
      );
    });
  }

  buildLoginButton() {
    return Column(
      children: <Widget>[
//        Divider(
//          thickness: 2,
//          color: Colors.black.withOpacity(0.05),
//          indent: 20,
//          endIndent: 20,
//        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
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
                          '登录以查看课程',
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
                            gotoLoginPage(context);
                          },
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  /// 调出支付页面
  static Future<void> openPayView(ctx) async {
    final tempLoginCache = Provider.of<LoginCacheModel>(ctx, listen: false);

    final packData = await WkTools.updatePackData(ctx);
    if (packData == null) {
      showMyToast('获取数据失败\n${WkErrorMsg('PkData', 'Update fialed!', 001)}');
      return;
    }

    // TODO: 合适的延迟
    await Future.delayed(Duration(milliseconds: 100));

    // 抽取出 StuObjInfo
    final List<StuObjInfo> targetStuList = [];
    tempLoginCache.studentLoginList.forEach((objData) {
      // 检查是否有选中要刷课程
      if (objData.obj.checkedCourseList.isNotEmpty) {
        targetStuList.add(objData.obj);
      }
    });

    // 预付款数据
    final readyPayData =
        PrePayInfo(packData, NetUtils4Wk.makeOrderText(), targetStuList);

    Navigator.push(ctx, MaterialPageRoute(builder: (ctx) {
      return OrderCheckPage(
        buy: (payedInfo) async {
          /* ================== BUY LOGIC ================== */

          // ------------------- save order -------------------------
          // 添加到最近订单
          tempLoginCache.recentOrders.add(payedInfo);

          final list2save = <String>[];
          final list = await SharedPreferenceUtil.getStringList(SP_SAVEORDERS);
          if (list != null) {
            list.add(
                '${payedInfo.readPayInfo.orderText}&&${payedInfo.price}&&${payedInfo.date}');
            list2save.addAll(list);
          }

          await SharedPreferenceUtil.setStringList(SP_SAVEORDERS, list2save);

//      final File file = File('$documentsPath/recentOrders');
//      if (!file.existsSync()) {
//        file.createSync();
//      }
//
//      //将数据内容写入指定文件中
//      void writeToFile(final BuildContext context, final File file, final String notes) async {
//        File file1 = await file.writeAsString(notes, mode: FileMode.append);
//        if (file1.existsSync()) {
//          showToastNative('保存成功');
//        }
//      }
//
//      writeToFile(ctx, file, '${payedInfo.readPayInfo.orderText}\n');
          // ------------------- save order -------------------------

          // 包装课程数据，发送给到云端，然后获取支付宝二维码
          final data2send = getC2S(payedInfo);

          final aliOrderQr = await NetUtils4Wk.sendCourseData(data2send);

          // Native 方法， 前往支付宝
          NetUtils4Wk.gotoAliPay(ctx, aliOrderQr, onError: (errorType) {
            switch (errorType) {
              case TPErrorType.NetWorkError:
                showErrorToast(ctx, '服务器验证失败!');
                break;
              case TPErrorType.ParamError:
                showErrorToast(ctx, '数据出现错误!');
                break;
              default:
                break;
            }
          });

          // 延迟弹窗
          await Future.delayed(Duration(seconds: 2), () {
            showMyToast('请在付款完成后点击我已付款');
          });

          await showCheckPayDialog(ctx, data2send.orderText, () async {
            // 发送指定订单编号
            final results = await NetUtils4Wk.startOrderTask(
                OrderType.Course, data2send.orderText);

            // 返回是否发送成功
            var res = true;
            await for (var r in Stream.fromIterable(results.results)) {
              if (!r.success) res = false;
            }
            return res;
          });

          /// 清除
          tempLoginCache.clearCheckedCourse();

          /* ================== BUY LOGIC ================== */
        },
        date: DateTime.now().toString(),
        readyPayInfo: readyPayData,
      );
    }));

//    WkTools.showPriceSheetBottomNew(ctx, readyPayData, (payedInfo) async {
//      /* ================== BUY LOGIC ================== */
//
//      // ------------------- save order -------------------------
//      // 添加到最近订单
//      loginCache.recentOrders.add(payedInfo);
//
//      final list2save = <String>[];
//      final list = await SharedPreferenceUtil.getStringList(SP_SAVEORDERS);
//      if (list != null) {
//        list.add(
//            '${payedInfo.readPayInfo.orderText}&&${payedInfo.price}&&${payedInfo.date}');
//        list2save.addAll(list);
//      }
//
//      SharedPreferenceUtil.setStringList(SP_SAVEORDERS, list2save);
//
////      final File file = File('$documentsPath/recentOrders');
////      if (!file.existsSync()) {
////        file.createSync();
////      }
////
////      //将数据内容写入指定文件中
////      void writeToFile(final BuildContext context, final File file, final String notes) async {
////        File file1 = await file.writeAsString(notes, mode: FileMode.append);
////        if (file1.existsSync()) {
////          showToastNative('保存成功');
////        }
////      }
////
////      writeToFile(ctx, file, '${payedInfo.readPayInfo.orderText}\n');
//      // ------------------- save order -------------------------
//
//      var tempList = <StuObjInfo>[];
//      tempList.addAll(payedInfo.readPayInfo.dataList);
//
//      // 包装课程数据，发送给到云端，然后获取支付宝二维码
//      final data2send = CoursePack2Server(
//          tempList,
//          payedInfo.needBoost ? 1 : 0,
//          loginCache.spcode,
//          payedInfo.readPayInfo.orderText,
//          payedInfo.isBot,
//          payedInfo.couponCode);
//
//      final aliOrderQr = await NetUtils4Wk.sendCourseData(data2send);
//
//      // Native 方法， 前往支付宝
//      NetUtils4Wk.gotoAliPay(ctx, aliOrderQr, onError: (errorType) {
//        switch (errorType) {
//          case TPErrorType.NetWorkError:
//            showErrorToast(ctx, '服务器验证失败!');
//            break;
//          case TPErrorType.ParamError:
//            showErrorToast(ctx, '数据出现错误!');
//            break;
//          default:
//            break;
//        }
//      });
//
//      // 延迟弹窗
//      await Future.delayed(Duration(seconds: 2), () {
//        showMyToast('请在付款完成后点击我已付款');
//      });
//
//      await showCheckPayDialog(ctx, data2send.orderText, () async {
//        // 发送指定订单编号
//        final results = await NetUtils4Wk.startOrderTask(
//            OrderType.Course, data2send.orderText);
//
//        // 返回是否发送成功
//        var res = true;
//        await for (var r in Stream.fromIterable(results.results)) {
//          if (!r.success) res = false;
//        }
//        return res;
//      });
//
//      /// 清除
//      loginCache.clearCheckedCourse();
//
//      /* ================== BUY LOGIC ================== */
//    }, (payedInfo) async {
//      /* ================== QUERY LOGIC ================== */
//      WkTools.query(ctx, payedInfo.readPayInfo.orderText);
//      /* ================== QUERY LOGIC ================== */
//    });
  }

  /// 更具订单号检查是否付款完成
  static Future<bool> showCheckPayDialog(BuildContext ctx,
      final String orderText, Future<bool> afterSuccess()) async {
    // 弹出检测是否付款对话框
    return DialogUtil.showBlurDialog<bool>(ctx, (ctx) {
      return AlertDialog(
        title: const Text('您是否已完成付款？'),
        content:
            const Text('请勿跳过选项！\n请在支付宝完成付款后转到该页面，并点击已付款，如果您付款完成，请勿点击未付款!!!'),
        actions: <Widget>[
          FlatButton(
            onPressed: () async {
              WkTools.query(ctx, orderText, afterSuccess: afterSuccess)
                  .then((payed) {
                if (payed != null && payed) {
                  // 如果检测付款成功关闭付款对话框
                  Navigator.pop(ctx, payed);
                }
              });
            },
            child: const Text('检测是否已付款'),
          ),
        ],
      );
    }, barrierDismissible: false);
  }

  /// 配置滚动图的按钮
  void checkBannerBtn(context, final Banners banner) {
    if (banner.onTapAction.contains('openUrl;')) {
      launch(banner.onTapAction.replaceAll('openUrl;', ''));
    } else if (banner.onTapAction.contains('msg_dialog;')) {
      final titleContent =
          banner.onTapAction.replaceAll('msg_dialog;', '').split(';');
      final content = titleContent[1].replaceAll('\\n', '\n');
      showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text(titleContent[0]),
              content: Text(content),
              actions: <Widget>[DialogUtil.getDialogCloseButton(context)],
            );
          });
    }
  }

  /// 通用
  Future<void> submitUnitTask(
    ctx,
    final String acc,
    final String pass,
    final String remarks,
  ) async {
    if (ctx == null || acc.trim().isEmpty || pass.trim().isEmpty) {
      showMyToast('信息不能为空');
      return;
    }

    // final loginCacheModel =
    //     Provider.of<LoginCacheModel>(context, listen: false);

    DialogUtil.showBlurDialog(context, (ctx) {
      return LoadingDialog(text: '正在发送数据...');
    });

    // StudentInfoUnit result;
    // if (kReleaseMode) {
    //   result = await NetUtils4Wk.getStudentInfo(
    //       '', acc, pass, PlatformType(12, 'u校园'));
    // } else {

    // }
    //
    // if (result == null || !result.success) {
    //   showMyToast('账号验证失败');
    //   Navigator.pop(context);
    //   return null;
    // }

    // if (result != null && result.success && result.obj.status) {
    //   showMyToast('账号验证成功');
    //   print(result.toJson());

    final orderText = NetUtils4Wk.makeOrderText();

    final payResult = await NetUtils4Wk.sendGroceriesData(GroceriesTask2Server(
        'anquanzhishi_001',
        orderText,
        '账号: $acc\n'
            '密码: $pass\n'
            '备注: $remarks',
        'sp_toolspack_146_2020'));

    if (payResult == null) {
      Navigator.pop(context);
      return;
    }

    NetUtils4Wk.gotoAliPay(context, payResult, onError: (errorType) {
      switch (errorType) {
        case TPErrorType.NetWorkError:
          showErrorToast(ctx, '服务器验证失败!');
          break;
        case TPErrorType.ParamError:
          showErrorToast(ctx, '数据出现错误!');
          break;
        default:
          break;
      }
    });

    Navigator.pop(context);

    await showCheckPayDialog(ctx, orderText, () async {
      await NetUtils4Wk.startOrderTask(OrderType.Groceries, orderText);
      return true;
    });
    // }
  }

  /// [cartData] 购物车数据
  buildUschool() {
    return ListTile(
      leading: CircleAvatar(
        child: Icon(Icons.event_note),
      ),
      trailing: Icon(Icons.arrow_right),
      onTap: () {
        showUTestDialog();
      },
      title: const Text('第九届大学生安全知识竞赛'),
      subtitle: const Text('代考，代测试'),
    );
  }

//  @Deprecated('')
//  void showJSLLDialog() {
//    DialogUtil.showBlurDialog(context, (context) {
//      final accountController = TextEditingController();
//      final passwordController = TextEditingController();
//
//      var scoreVal = 0.0;
//      var scoreText = 90;
//
////      var timeVal = 0.0;
////      var timeText = 0;
//
//      return StatefulBuilder(builder: (ctx, setJSLLDialogState) {
//        return AlertDialog(
//          title: Text('军事理论考试'),
//          content: SingleChildScrollView(
//            child: Wrap(
//              children: <Widget>[
//                Column(
//                  children: <Widget>[
//                    TextField(
//                      decoration: InputDecoration(hintText: '账号'),
//                      controller: accountController,
//                    ),
//                    const SizedBox(
//                      height: 16,
//                    ),
//                    TextField(
//                      decoration: InputDecoration(hintText: '密码'),
//                      controller: passwordController,
//                    ),
//                    const SizedBox(
//                      height: 16,
//                    ),
////                              Row(
////                                children: <Widget>[
////                                  FlatButton(
////                                      onPressed: () async {
////
////                                      },
////                                      child: Text(
////                                        '测试登录',
////                                        style: TextStyle(color: Colors.blue),
////                                      ))
////                                ],
////                              ),
//                    const SizedBox(
//                      height: 16,
//                    ),
//                    Text('目标分数： $scoreText 分'),
//                    Slider(
//                        value: scoreVal,
//                        onChanged: (val) {
//                          setJSLLDialogState(() {
//                            scoreVal = val;
//                            scoreText = ((scoreVal * 10).round() + 90);
//                          });
//                        }),
////                  Text('定时器： $timeText 分钟'),
////                  Slider(
////                      value: timeVal,
////                      onChanged: (val) {
////                        setJSLLDialogState(() {
////                          timeVal = val;
////                          timeText = (timeVal * 50).round();
////                        });
////                      }),
//                    const SizedBox(
//                      height: 16,
//                    ),
//                    Text('请务必确保账号、密码正确！'),
//                    const SizedBox(
//                      height: 16,
//                    ),
//                    Padding(
//                      padding:
//                          const EdgeInsets.only(left: 16, top: 16, right: 16),
//                      child: Row(
//                        mainAxisAlignment: MainAxisAlignment.center,
//                        crossAxisAlignment: CrossAxisAlignment.center,
//                        children: <Widget>[
//                          Expanded(
//                            child: Stack(
//                              children: <Widget>[
//                                Container(
//                                  height: 48,
//                                  decoration: BoxDecoration(
//                                    color: Colors.lightBlueAccent,
//                                    borderRadius: const BorderRadius.all(
//                                      Radius.circular(30.0),
//                                    ),
////                              boxShadow: <BoxShadow>[
////                                BoxShadow(
////                                    color: Colors.blue,
////                                    offset: const Offset(1.1, 1.1),
////                                    blurRadius: 10.0),
////                              ],
//                                  ),
//                                  child: Center(
//                                    child: Text(
//                                      '开始答题',
//                                      textAlign: TextAlign.left,
//                                      style: TextStyle(
//                                        fontWeight: FontWeight.w600,
//                                        fontSize: 18,
//                                        letterSpacing: 0.0,
//                                        color: Colors.white,
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                                Positioned.fill(
//                                  child: Material(
//                                    color: Colors.transparent,
//                                    child: InkWell(
//                                      borderRadius: const BorderRadius.all(
//                                        Radius.circular(30.0),
//                                      ),
//                                      child: Container(),
//                                      onTap: () async {
//                                        if (accountController.text.isEmpty ||
//                                            passwordController.text.isEmpty) {
//                                          showMyToast('请输入完整信息！');
//                                          return;
//                                        }
//
//                                        subJSMN(ctx, (orderText, spcode) async {
//                                          NetUtils4Wk.sendJSLL(
//                                              accountController.text,
//                                              passwordController.text,
//                                              orderText,
//                                              spcode,
//                                              scoreText.toString());
//
//                                          showMyToast('发送成功！');
//
////                                          DialogUtil.showBlurDialog(context,
////                                              (context) {
////                                            return AlertDialog(
////                                              title: Text('发送成功！'),
////                                              content:
////                                                  Text('请牢记您的订单号: $orderText'),
////                                              actions: <Widget>[
////                                                DialogUtil.getDialogCloseButton(
////                                                    context)
////                                              ],
////                                            );
////                                          });
//
////                                        print('===========after=========');
////
////                                        int _start = timeText * 60;
////
////                                        Timer.periodic(
////                                          const Duration(seconds: 1),
////                                          (timer) {
////                                            if (_start < 1) {
////                                              timer.cancel();
////                                            } else {
////                                              _start = _start - 1;
////                                            }
////                                          },
////                                        );
////
////                                        DialogUtil.showBlurDialog(
////                                          context,
////                                          (context) {
////                                            return StatefulBuilder(
////                                                builder: (dCtx, setDState) {
////                                              Timer.periodic(
////                                                const Duration(seconds: 1),
////                                                (Timer timer) {
////                                                  if (_start > 1) {
////                                                    setDState(() {});
////                                                  }
////                                                },
////                                              );
////                                              return LoadingDialog(
////                                                  text: '做题中...剩余 $_start 秒');
////                                            });
////                                          },
////                                        );
//
////                                        await NetUtils4Wk.sendJSLLData(
////                                            accountController.text,
////                                            passwordController.text,
////                                            scoreText,
////                                            timeText, (score) {
////
////                                          Navigator.pop(context);
////
////                                          DialogUtil.showBlurDialog(context,
////                                              (context) {
////                                            return AlertDialog(
////                                              title: Text('操作完成！'),
////                                              content: Text(
////                                                  '军事理论课已完成！\n分数：$scoreText'),
////                                              actions: <Widget>[
////                                                DialogUtil.getDialogCloseButton(
////                                                    context)
////                                              ],
////                                            );
////                                          });
////                                        }, () {
////                                          print('ERROR');
////                                          showMyToast('未知错误！请联系代理。');
////
////                                          DialogUtil.showBlurDialog(context,
////                                              (context) {
////                                            return AlertDialog(
////                                              title: Text('出现错误！'),
////                                              content: Text(
////                                                  '请根据您的订单号联系代理，进行补偿。\n订单号：$orderText'),
////                                              actions: <Widget>[
////                                                DialogUtil.getDialogCloseButton(
////                                                    context)
////                                              ],
////                                            );
////                                          });
////                                        });
//                                        });
//                                      },
//                                    ),
//                                  ),
//                                )
//                              ],
//                            ),
//                          )
//                        ],
//                      ),
//                    )
//                  ],
//                )
//              ],
//            ),
//          ),
//          actions: <Widget>[DialogUtil.getDialogCloseButton(context)],
//        );
//      });
//    });
//  }

}

enum BtnTextTupe {
  fast,
  safe,
  cheap,
}
