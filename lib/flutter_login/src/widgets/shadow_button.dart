/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';

class ShadowButton extends StatelessWidget {
  ShadowButton({
    Key key,
    this.text,
    this.borderRadius = const BorderRadius.all(Radius.circular(0.0)),
    this.color,
    this.onPressed,
    this.onHighlightChanged,
    this.splashColor,
    this.width,
    this.height,
    this.boxShadow,
  }) : super(key: key);

  final String text;
  final BorderRadius borderRadius;
  final Color color;
  final Function onPressed;
  final ValueChanged<bool> onHighlightChanged;
  final Color splashColor;
  final double width;
  final double height;
  final BoxShadow boxShadow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final temp = [];

    if (boxShadow != null) temp.add(boxShadow);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.transparent,
        boxShadow: temp,
      ),
      child: Material(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        color: color,
        child: InkWell(
          onTap: onPressed,
          onHighlightChanged: onHighlightChanged,
          splashColor: splashColor,
          borderRadius: borderRadius,
          child: Container(
            width: width,
            height: height,
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(color: theme.primaryTextTheme.button.color),
              overflow: TextOverflow.visible,
              softWrap: false,
            ),
          ),
        ),
      ),
    );
  }
}
