/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared/config/theme_util.dart';

import '../../main.dart';
import 'navbar_button.dart';

class NavBar extends StatelessWidget {
  final ValueChanged<int> itemTapped;
  final int currentIndex;
  final List<NavBarItemData> items;

  NavBar({this.items, this.itemTapped, this.currentIndex = 0});

  NavBarItemData get selectedItem =>
      currentIndex >= 0 && currentIndex < items.length
          ? items[currentIndex]
          : null;

  @override
  Widget build(BuildContext context) {
    //For each item in our list of data, create a NavBtn widget
    List<Widget> buttonWidgets = items.map((data) {
      //Create a button, and add the onTap listener
      return NavBarButton(data, data == selectedItem, onTap: () {
        //Get the index for the clicked data
        var index = items.indexOf(data);
        //Notify any listeners that we've been tapped, we rely on a parent widget to change our selectedIndex and redraw
        itemTapped(index);
      });
    }).toList();

    // 创建一个包含一行的容器，然后将btn小部件添加到该行中
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
//        ThemeUtil.getLine(color: Theme.of(context).dividerColor),
        Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
                child: Container(
                  width: double.infinity,
                  height: ThemeUtil.navBarHeight,
                  decoration: BoxDecoration(
                      color: Theme.of(context)
                          .scaffoldBackgroundColor
                          .withOpacity(0.6)),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                // navBar 背景颜色
                color: Colors.transparent,
                // 在我们的导航栏中添加一些阴影，使用 2 可获得更好的效果
//            boxShadow: [
//              BoxShadow(blurRadius: 16, color: Colors.black12),
//              BoxShadow(blurRadius: 24, color: Colors.black12),
//            ],
              ),
              alignment: Alignment.center,
              height: 64,
              child: Container(
//                color: Colors.amber,
                child: Row(
                  // 水平居中按钮
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  // Inject a bunch of btn instances into our row
                  // 向我们的行中注入一堆btn实例
                  children: buttonWidgets,
                ),
              ),
              // 裁剪小部件行，以抑制动画期间可能发生的任何溢出错误
//              child: ClippedView(
//                child: Container(
//                  color: Colors.amber,
//                  child: Row(
//                    // 水平居中按钮
//                    mainAxisAlignment: MainAxisAlignment.center,
//                    // Inject a bunch of btn instances into our row
//                    // 向我们的行中注入一堆btn实例
//                    children: buttonWidgets,
//                  ),
//                ),
//              ),
            )
          ],
        )
      ],
    );
  }
}

class NavBarItemData {
  final String title;
  final IconData icon;
  final Color selectedColor;
  final double width;

  NavBarItemData(this.title, this.icon, this.width, this.selectedColor);
}
