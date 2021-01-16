/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';

class MySquareIndicator extends StatefulWidget {
  final int length;
  final int select;
  final Widget selectorWidget;
  final Widget normalWidget;

  MySquareIndicator(
      {Key key,
      this.length,
      this.select,
      this.selectorWidget,
      this.normalWidget})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyMSquareIndicator(length, select);
  }
}

class MyMSquareIndicator extends State<MySquareIndicator> {
  var _length = 0;
  var _select = 0;

  MyMSquareIndicator(this._length, this._select);

  List<Widget> points() {
    List<Widget> list;
    for (var i = 0; i < _length; i++) {
      if (list == null) {
        list = new List();
      }
      list.add(_getWidget(i));
    }
    if (list == null) {
      list = new List();
      list.add(Container());
    }
    return list;
  }

  Widget _getWidget(int i) {
    int index = _select;

    if (index == i) {
      if (widget.selectorWidget != null) {
        return widget.selectorWidget;
      }
      return Container(
        margin: EdgeInsets.only(left: 4, right: 4),
        width: 10,
        height: 4,
        color: Colors.black.withOpacity(0.6),
      );
    } else {
      if (widget.normalWidget != null) {
        return widget.normalWidget;
      }
      return Container(
        margin: EdgeInsets.only(left: 4, right: 4),
        width: 10,
        height: 4,
        color: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: points(),
    );
  }

  updateWidgets(int length, int select) {
    _length = length;
    _select = select;
    setState(() {});
  }
}
