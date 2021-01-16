/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

import 'package:flutter/material.dart';

class LoginMessages with ChangeNotifier {
  LoginMessages({
    this.usernameHint: defaultUsernameHint,
    this.passwordHint: defaultPasswordHint,
    this.confirmPasswordHint: defaultConfirmPasswordHint,
    this.forgotPasswordButton: defaultForgotPasswordButton,
    this.loginButton: defaultLoginButton,
    this.signupButton: defaultSignupButton,
    this.recoverPasswordButton: defaultRecoverPasswordButton,
    this.recoverPasswordIntro: defaultRecoverPasswordIntro,
    this.recoverPasswordDescription: defaultRecoverPasswordDescription,
    this.goBackButton: defaultGoBackButton,
    this.confirmPasswordError: defaultConfirmPasswordError,
    this.recoverPasswordSuccess: defaultRecoverPasswordSuccess,
  });

  static const defaultUsernameHint = '账号-电子邮箱';
  static const defaultPasswordHint = '密码';
  static const defaultConfirmPasswordHint = '确认密码';
  static const defaultForgotPasswordButton = '忘记密码?';
  static const defaultLoginButton = '登录';
  static const defaultSignupButton = '注册';
  static const defaultRecoverPasswordButton = '恢复';
  static const defaultRecoverPasswordIntro = '在这里重新设置你的密码';
  static const defaultRecoverPasswordDescription = '我们会将您的纯文本密码发送到该电子邮件帐户。';
  static const defaultGoBackButton = '返回';
  static const defaultConfirmPasswordError = '密码不匹配!';
  static const defaultRecoverPasswordSuccess = '邮件已发送';

  /// Hint text of the user name [TextField]
  final String usernameHint;

  /// Hint text of the password [TextField]
  final String passwordHint;

  /// Hint text of the confirm password [TextField]
  final String confirmPasswordHint;

  /// Forgot password button's label
  final String forgotPasswordButton;

  /// Login button's label
  final String loginButton;

  /// Signup button's label
  final String signupButton;

  /// Recover password button's label
  final String recoverPasswordButton;

  /// Intro in password recovery form
  final String recoverPasswordIntro;

  /// Description in password recovery form
  final String recoverPasswordDescription;

  /// Go back button's label. Go back button is used to go back to to
  /// login/signup form from the recover password form
  final String goBackButton;

  /// The error message to show when the confirm password not match with the
  /// original password
  final String confirmPasswordError;

  /// The success message to show after submitting recover password
  final String recoverPasswordSuccess;
}
