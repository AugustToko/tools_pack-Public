/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:lingyun_widget/urls.dart';
import 'package:shared/config/global_settings.dart';
import 'package:toolspack/pages/web_page.dart';

exitApp(Function() befExit) async {
  befExit?.call();
  return await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

gotoBlogGeekReg(context) => FlutterWebBrowser.openWebPage(
    url: BLOG_GEEK_REG, androidToolbarColor: Theme.of(context).primaryColor);

gotoBlogGeekForgot(context) => FlutterWebBrowser.openWebPage(
    url: BLOG_GEEK_REST_PWD,
    androidToolbarColor: Theme.of(context).primaryColor);

gotoUserAgreementPage(context) =>
    Navigator.pushNamed(context, WebPage.routeName,
        arguments: {"title": "用户协议", "url": UserAgreementUrl});

gotoUserPrivacyPolicyPage(context) =>
    Navigator.pushNamed(context, WebPage.routeName,
        arguments: {"title": "隐私政策", "url": PrivacyPolicyUrl});

gotoUPostsPageByArg(final context, final String url, {final AppBar appBar}) {
  Navigator.of(context).pushNamed(GlobalSettings.argPostsPageRouteName,
      arguments: {'url': url, 'appBar': appBar});
}

goToProfilePage(final context, final int userId) {
  Navigator.pushNamed(context, GlobalSettings.profileRouteName,
      arguments: {"wpUserId": userId});
}

goToLoginPage(final context) {
  Navigator.pushNamed(context, GlobalSettings.loginRouteName);
}
