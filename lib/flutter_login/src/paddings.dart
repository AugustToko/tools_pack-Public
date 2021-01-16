/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';

class Paddings {
  static EdgeInsets fromLTR(double value) {
    return EdgeInsets.only(
      left: value,
      top: value,
      right: value,
    );
  }

  static EdgeInsets fromRBL(double value) {
    return EdgeInsets.only(
      right: value,
      bottom: value,
      left: value,
    );
  }
}
