/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:toolspack/pages/permission_page.dart';
import 'package:toolspack/utils/shared_prefs.dart';
import 'package:toolspack/utils/shared_prefs_key.dart';

import 'main_page.dart';

class IntroScreen extends StatefulWidget {
  final bool review;

  const IntroScreen({Key key, this.review = false}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _IntroScreenState();
  }
}

class _IntroScreenState extends State<IntroScreen> {
  List<Slide> slides = List();

  @override
  void initState() {
    super.initState();

    slides.add(
      Slide(
        title: '丰富多样',
        description: '我们支持多种多样的平台: 超星、智慧树、中国大学MOOC',
        pathImage: 'assets/images/helpImage.png',
        backgroundColor: Color(0xfff5a623),
      ),
    );
    slides.add(
      Slide(
        title: '简洁便用',
        description: '我们提供内置的查询方法，可以让您一栏自己的平台课程。并选择合适的解决方案！',
        pathImage: 'assets/images/inviteImage.png',
        backgroundColor: Color(0xff203152),
      ),
    );
    slides.add(
      Slide(
        title: "安全稳定",
        description: '四年老平台，历经风雨。全网最先进安全的自动化操作，并提供更加安全的人工操作！',
        pathImage: 'assets/images/feedbackImage.png',
        backgroundColor: Color(0xff9932CC),
      ),
    );
  }

  Future<void> onDonePress() async {
    if (widget.review) {
      Navigator.pop(context);
      return;
    }

    SharedPreferenceUtil.setBool(SharedPrefsKeys.IS_FIRST_ENTER_APP, false);

    if (!kIsWeb) {
      final result = await PermissionPage.checkPermission();
      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        return result ? MainPage() : PermissionPage();
      }));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (ctx) {
        return MainPage();
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroSlider(
      slides: this.slides,
      onDonePress: this.onDonePress,
    );
  }
}
