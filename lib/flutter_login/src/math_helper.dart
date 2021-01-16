/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'dart:math';

class MathHelper {
  static double toRadian(double degree) => degree * pi / 180;

  static double lerp(double start, double end, double percent) {
    return (start + percent * (end - start));
  }
}
