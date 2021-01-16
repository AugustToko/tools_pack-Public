/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lingyun_widget/dialog_util.dart';
import 'package:lingyun_widget/toast.dart';
import 'package:outline_material_icons/outline_material_icons.dart';

import '../main.dart';
import '../toolspack_theme.dart';

class GlassView extends StatelessWidget {
  final AnimationController animationController;
  final Animation animation;
  final String text;
  final bool showIcon;

  const GlassView(
      {Key key,
      this.animationController,
      this.animation,
      this.text,
      this.showIcon = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Container(
          decoration: BoxDecoration(
            color: HexColor("#D7E0F9"),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8.0),
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
                topRight: Radius.circular(8.0)),
            // boxShadow: <BoxShadow>[
            //   BoxShadow(
            //       color: FintnessAppTheme.grey.withOpacity(0.2),
            //       offset: Offset(1.1, 1.1),
            //       blurRadius: 10.0),
            // ],
          ),
          child: Padding(
            padding: EdgeInsets.only(
                left: showIcon ? 68 : 12, bottom: 12, right: 16, top: 12),
            child: Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  text,
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontFamily: ToolsPackAppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    letterSpacing: 0.0,
                    color: ToolsPackAppTheme.nearlyDarkBlue.withOpacity(0.6),
                  ),
                ))
              ],
            ),
          ),
        ),
      ),
    ];

    if (showIcon) {
      widgets.add(Positioned(
        child: SizedBox(
          width: 50,
          height: 50,
          child: CircleAvatar(
            child: Icon(
              OMIcons.notifications,
              size: 35,
            ),
          ),
        ),
        top: 5,
        left: 8,
      ));
    }

    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: new Matrix4.translationValues(
                0.0, 30 * (1.0 - animation.value), 0.0),
            child: InkWell(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 0, right: 0, top: 0, bottom: 10),
                child: Stack(
                  overflow: Overflow.visible,
                  children: widgets,
                ),
              ),
              onTap: () {
                DialogUtil.showBlurDialog(context, (ctx) {
                  return AlertDialog(
                    title: Text('公告'),
                    content: Text('$text'),
                    actions: <Widget>[DialogUtil.getDialogCloseButton(context)],
                  );
                });
              },
              onLongPress: () {
                Clipboard.setData(ClipboardData(text: text));
                showMyToast('已复制');
              },
            ),
          ),
        );
      },
    );
  }
}
