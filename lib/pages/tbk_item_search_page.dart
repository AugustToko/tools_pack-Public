/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:taobaoke_shared/rep/wp_rep.dart';
import 'package:taobaoke_shared/widget/tbk_item_search_widget.dart';
import 'package:toolspack/design_course/design_course_app_theme.dart';

import '../main.dart';

/// [MainPage]
/// 仅带有一个 BottomNavigationBar
class TbkSearchPage extends StatefulWidget {
  static const routeName = "/TbkSearchPage";

  final String keyWord;

  const TbkSearchPage({Key key, this.keyWord}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TbkSearchPageState();
  }
}

class _TbkSearchPageState extends State<TbkSearchPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          TbkSearchWidget(
            TbkShRep(widget.keyWord, oaid: OAID),
            oaid: OAID,
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
                padding: EdgeInsets.only(
                  top: 45,
                  right: 16,
                  left: 16,
                ),
                child: Row(
                  children: <Widget>[
                    IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '查券助手',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              letterSpacing: 0.2,
                              color: DesignCourseAppTheme.grey,
                            ),
                          ),
                          Text(
                            '${widget.keyWord} 的搜索结果',
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

//  Widget getMaterialItem() {
//    return FutureBuilder<TbkOptimusItem>(
//      builder: (context, snapshot) {
//        if (snapshot.hasData && snapshot.data != null) {
//          final data =
//              snapshot.data.tbkDgOptimusMaterialResponse.resultList.mapData;
//          return Column(
//            children: List<Widget>.generate(data.length, (index) {
//              final itemData = data[index];
//              return Container(
//                margin: EdgeInsets.only(top: 0, left: 8, right: 8),
//                child: Column(
//                  children: <Widget>[
//                    Padding(
//                      padding: EdgeInsets.all(8),
//                      child: Row(
//                        crossAxisAlignment: CrossAxisAlignment.start,
//                        mainAxisAlignment: MainAxisAlignment.start,
//                        children: <Widget>[
//                          ExtendedImage.network(
//                            'https:${itemData.pictUrl}',
//                            width: 100,
//                          ),
//                          const SizedBox(
//                            width: 12,
//                          ),
//                          Column(
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: <Widget>[
//                              Container(
//                                width: MediaQuery.of(context).size.width * 0.63,
//                                child: Text(
//                                  itemData.shortTitle,
//                                  style: TextStyle(fontSize: 16),
//                                  overflow: TextOverflow.ellipsis,
//                                  maxLines: 3,
//                                ),
//                              )
//                            ],
//                          )
//                        ],
//                      ),
//                    ),
//                    Divider()
//                  ],
//                ),
//              );
//            }),
//          );
//        } else {
//          return SizedBox();
//        }
//      },
//      future: TaoBaoKeNetTools.getMtData(),
//    );
//  }
}
