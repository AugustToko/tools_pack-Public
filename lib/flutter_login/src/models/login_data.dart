/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/foundation.dart';

class LoginData {
  final String name;
  final String password;

  LoginData({
    @required this.name,
    @required this.password,
  });

  @override
  String toString() {
    return '$runtimeType($name, $password)';
  }

  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name && password == other.password;
    }
    return false;
  }

  int get hashCode => name.hashCode + password.hashCode;
}
