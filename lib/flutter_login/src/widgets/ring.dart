/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';

/// A circle with a hole
class Ring extends StatelessWidget {
  Ring({
    Key key,
    this.color,
    this.size = 40.0,
    this.thickness = 2.0,
    this.value = 1.0,
  })  : assert(size - thickness > 0),
        assert(thickness >= 0),
        super(key: key);

  final Color color;
  final double size;
  final double thickness;
  final double value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size - thickness,
      height: size - thickness,
      child: thickness == 0
          ? null
          : CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(color),
              strokeWidth: thickness,
              value: value,
            ),
    );
  }
}
