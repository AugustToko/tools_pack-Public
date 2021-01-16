/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toolspack_shared/model/pack_data.dart';
import 'package:toolspacklibs/model/login_cache.dart';
import 'package:toolspacklibs/utils/net_utils.dart';

import '../main.dart';
import 'design_course_app_theme.dart';

class CategoryListView extends StatefulWidget {
  const CategoryListView({Key key, this.callBack}) : super(key: key);

  final Function(CategoryJson category) callBack;

  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView>
    with TickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  // TODO: 优化获取次数
  Future<PackData> getData() async {
    // model
    final loginCacheModel =
        Provider.of<LoginCacheModel>(context, listen: false);

    var packData =
        await NetUtils4Wk.getToolsPackData(spcode: loginCacheModel.spcode);
    if (packData != null) loginCacheModel.packData = packData;
    return packData;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      child: Container(
        height: 134,
        width: double.infinity,
        child: FutureBuilder<PackData>(
          future: getData(),
          builder: (BuildContext context, AsyncSnapshot<PackData> snapshot) {
            if (!snapshot.hasData ||
                snapshot.data == null ||
                snapshot.data.categories.length == 0) {
              return const SizedBox();
            } else {
              return ListView.builder(
                padding: const EdgeInsets.only(
                    top: 0, bottom: 0, right: 16, left: 16),
                itemCount: snapshot.data.categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context, int index) {
                  final int count = snapshot.data.categories.length;

                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                              parent: animationController,
                              curve: Interval((1 / count) * index, 1.0,
                                  curve: Curves.fastOutSlowIn)));

                  animationController.forward();

                  var c = snapshot.data.categories[index];
                  return CategoryView(
                    category: c,
                    animation: animation,
                    animationController: animationController,
                    callback: () {
                      widget.callBack(c);
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class CategoryView extends StatelessWidget {
  const CategoryView(
      {Key key,
      this.category,
      this.animationController,
      this.animation,
      this.callback})
      : super(key: key);

  final VoidCallback callback;
  final CategoryJson category;
  final AnimationController animationController;
  final Animation<dynamic> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation.value), 0.0, 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              onTap: () {
                callback();
              },
              child: SizedBox(
                width: 280,
                child: Stack(
                  children: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          const SizedBox(
                            width: 48,
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: HexColor('#F8FAFB'),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16.0)),
                              ),
                              child: Row(
                                children: <Widget>[
                                  const SizedBox(
                                    width: 48 + 24.0,
                                  ),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 16),
                                            child: Text(
                                              category.title,
                                              textAlign: TextAlign.left,
                                              maxLines: 1,
                                              overflow: TextOverflow.fade,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                                letterSpacing: 0.27,
                                                color: DesignCourseAppTheme
                                                    .darkerText,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                right: 16, bottom: 8),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
//                                                Text(
//                                                  '${category.lessonCount} lesson',
//                                                  textAlign: TextAlign.left,
//                                                  style: TextStyle(
//                                                    fontWeight: FontWeight.w200,
//                                                    fontSize: 12,
//                                                    letterSpacing: 0.27,
//                                                    color: DesignCourseAppTheme
//                                                        .grey,
//                                                  ),
//                                                ),
                                                Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        '${category.rating}',
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w200,
                                                          fontSize: 18,
                                                          letterSpacing: 0.27,
                                                          color:
                                                              DesignCourseAppTheme
                                                                  .grey,
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.star,
                                                        color:
                                                            DesignCourseAppTheme
                                                                .nearlyBlue,
                                                        size: 20,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
//                                          Padding(
//                                            padding: const EdgeInsets.only(
//                                                bottom: 16, right: 16),
//                                            child: Row(
//                                              mainAxisAlignment:
//                                                  MainAxisAlignment
//                                                      .spaceBetween,
//                                              crossAxisAlignment:
//                                                  CrossAxisAlignment.start,
//                                              children: <Widget>[
//                                                Text(
//                                                  '\￥${category.money}',
//                                                  textAlign: TextAlign.left,
//                                                  style: TextStyle(
//                                                    fontWeight: FontWeight.w600,
//                                                    fontSize: 18,
//                                                    letterSpacing: 0.27,
//                                                    color: DesignCourseAppTheme
//                                                        .nearlyBlue,
//                                                  ),
//                                                ),
//                                                Container(
//                                                  decoration: BoxDecoration(
//                                                    color: DesignCourseAppTheme
//                                                        .nearlyBlue,
//                                                    borderRadius:
//                                                        const BorderRadius.all(
//                                                            Radius.circular(
//                                                                8.0)),
//                                                  ),
//                                                  child: Padding(
//                                                    padding:
//                                                        const EdgeInsets.all(
//                                                            4.0),
//                                                    child: Icon(
//                                                      Icons.add,
//                                                      color:
//                                                          DesignCourseAppTheme
//                                                              .nearlyWhite,
//                                                    ),
//                                                  ),
//                                                )
//                                              ],
//                                            ),
//                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 24, bottom: 24, left: 16),
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16.0)),
                              child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Material(
                                    child: Image.asset(category.imagePath),
                                    color: Colors.white,
                                  )),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
