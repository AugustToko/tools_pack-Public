/*
 * Project: tools_pack Public
 * Module: toolspack
 * Last Modified: 21-1-16 下午12:40
 * Copyright (c) 2021 August https://blog.geek-cloud.top/
 */

library flutter_login;

import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'package:provider/provider.dart';
import 'package:toolspack/flutter_login/src/color_helper.dart';
import 'package:toolspack/flutter_login/src/constants.dart';
import 'package:toolspack/flutter_login/src/dart_helper.dart';
import 'package:toolspack/flutter_login/src/providers/auth.dart';
import 'package:toolspack/flutter_login/src/providers/login_messages.dart';
import 'package:toolspack/flutter_login/src/providers/login_theme.dart';
import 'package:toolspack/flutter_login/src/regex.dart';
import 'package:toolspack/flutter_login/src/widgets/auth_card.dart';
import 'package:toolspack/flutter_login/src/widgets/fade_in.dart';
import 'package:toolspack/flutter_login/src/widgets/gradient_box.dart';
import 'package:toolspack/flutter_login/src/widgets/null_widget.dart';
import 'package:toolspack/flutter_login/theme.dart';

class _AnimationTimeDilationDropdown extends StatelessWidget {
  _AnimationTimeDilationDropdown({
    @required this.onChanged,
    this.initialValue = 1.0,
  });

  final Function onChanged;
  final double initialValue;
  static const animationSpeeds = const [1, 2, 5, 10];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'x1 is normal time, x5 means the animation is 5x times slower for debugging purpose',
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 125,
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(
                initialItem: animationSpeeds.indexOf(initialValue.toInt()),
              ),
              itemExtent: 30.0,
              backgroundColor: Colors.white,
              onSelectedItemChanged: onChanged,
              children: animationSpeeds.map((x) => Text('x$x')).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatefulWidget {
  _Header({
    this.logoPath,
    this.logoTag,
    this.title,
    this.titleTag,
    this.height = 250.0,
    this.logoController,
    this.titleController,
    @required this.loginTheme,
  });

  final String logoPath;
  final String logoTag;
  final String title;
  final String titleTag;
  final double height;
  final LoginTheme loginTheme;
  final AnimationController logoController;
  final AnimationController titleController;

  @override
  __HeaderState createState() => __HeaderState();
}

class __HeaderState extends State<_Header> {
  double _titleHeight = 0.0;

  /// https://stackoverflow.com/a/56997641/9449426
  double getEstimatedTitleHeight() {
    if (DartHelper.isNullOrEmpty(widget.title)) {
      return 0.0;
    }

    final theme = Theme.of(context);
    final renderParagraph = RenderParagraph(
      TextSpan(
        text: widget.title,
        style: theme.textTheme.display2.copyWith(
          fontSize: widget.loginTheme.beforeHeroFontSize,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    renderParagraph.layout(BoxConstraints());

    return renderParagraph
        .getMinIntrinsicHeight(widget.loginTheme.beforeHeroFontSize)
        .ceilToDouble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _titleHeight = getEstimatedTitleHeight();
  }

  @override
  void didUpdateWidget(_Header oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.title != oldWidget.title) {
      _titleHeight = getEstimatedTitleHeight();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const gap = 5.0;
    final logoHeight = min(widget.height - _titleHeight - gap, kMaxLogoHeight);
    final displayLogo = widget.logoPath != null && logoHeight >= kMinLogoHeight;

    Widget logo = displayLogo
        ? Column(
            children: <Widget>[
              Image.asset(
                widget.logoPath,
                filterQuality: FilterQuality.high,
                height: logoHeight,
                color: Colors.white,
              ),
              //TODO: 非固定文本
              Text(
                " - Ling Yun Virtual Project - ",
                style: TextStyle(color: Colors.white),
              )
            ],
          )
        : NullWidget();

    if (widget.logoTag != null) {
      logo = Hero(
        tag: widget.logoTag,
        child: logo,
      );
    }

    Widget title;
//    if (widget.titleTag != null && !DartHelper.isNullOrEmpty(widget.title)) {
//      title = HeroText(
//        widget.title,
//        key: kTitleKey,
//        tag: widget.titleTag,
//        largeFontSize: widget.loginTheme.beforeHeroFontSize,
//        smallFontSize: widget.loginTheme.afterHeroFontSize,
//        style: theme.textTheme.display2,
//        viewState: ViewState.enlarged,
//      );
//    } else if (!DartHelper.isNullOrEmpty(widget.title)) {
//      title = Text(
//        widget.title,
//        key: kTitleKey,
//        style: theme.textTheme.display2,
//      );
//    } else {
    title = null;
//    }

    final tempWidgets = <Widget>[];
    if (displayLogo) {
      tempWidgets.add(FadeIn(
        controller: widget.logoController,
        offset: .25,
        fadeDirection: FadeDirection.topToBottom,
        child: logo,
      ));
    }

    tempWidgets.addAll([
      SizedBox(height: gap),
      FadeIn(
        controller: widget.titleController,
        offset: .5,
        fadeDirection: FadeDirection.topToBottom,
        child: title,
      ),
    ]);

    return SizedBox(
      height: widget.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: tempWidgets,
      ),
    );
  }
}

/// TODO: 修复 [onSignup] 和 [onRecoverPassword]
class FlutterLogin extends StatefulWidget {
  FlutterLogin({
    Key key,
    @required this.onSignup,
    @required this.onLogin,
    @required this.onRecoverPassword,
    this.title = 'LOGIN',
    this.logo,
    this.messages,
    this.theme,
    this.emailValidator,
    this.passwordValidator,
    this.onSubmitAnimationCompleted,
    this.logoTag,
    this.titleTag,
    this.showDebugButtons = true,
    this.background,
    this.onSignBtnPressed,
    this.onForgotBtnPressed,
  }) : super(key: key);

  /// Called when the user hit the submit button when in sign up mode
  final AuthCallback onSignup;

  /// Called when the user hit the submit button when in login mode
  final AuthCallback onLogin;

  /// Called when the user hit the submit button when in recover password mode
  final RecoverCallback onRecoverPassword;

  /// The large text above the login [Card], usually the app or company name
  final String title;

  /// The path to the asset image that will be passed to the `Image.asset()`
  final String logo;

  /// Describes all of the labels, text hints, button texts and other auth
  /// descriptions
  final LoginMessages messages;

  final Function onSignBtnPressed;

  final Function onForgotBtnPressed;

  /// FlutterLogin's theme. If not specified, it will use the default theme as
  /// shown in the demo gifs and use the colorsheme in the closest `Theme`
  /// widget
  final LoginTheme theme;

  /// Email validating logic, Returns an error string to display if the input is
  /// invalid, or null otherwise
  final FormFieldValidator<String> emailValidator;

  /// Same as [emailValidator] but for password
  final FormFieldValidator<String> passwordValidator;

  /// Called after the submit animation's completed. Put your route transition
  /// logic here. Recommend to use with [logoTag] and [titleTag]
  final Function onSubmitAnimationCompleted;

  /// Hero tag for logo image. If not specified, it will simply fade out when
  /// changing route
  final String logoTag;

  /// Hero tag for title text. Need to specify `LoginTheme.beforeHeroFontSize`
  /// and `LoginTheme.afterHeroFontSize` if you want different font size before
  /// and after hero animation
  final String titleTag;

  /// Display the debug buttons to quickly forward/reverse login animations. In
  /// release mode, this will be overrided to false regardless of the value
  /// passed in
  final bool showDebugButtons;

  final Widget background;

  static final FormFieldValidator<String> defaultEmailValidator = (value) {
    if (value.isEmpty || !Regex.email.hasMatch(value)) {
      return 'Invalid email!';
    }
    return null;
  };

  static final FormFieldValidator<String> defaultPasswordValidator = (value) {
    if (value.isEmpty || value.length <= 2) {
      return 'Password is too short!';
    }
    return null;
  };

  @override
  _FlutterLoginState createState() => _FlutterLoginState();
}

class _FlutterLoginState extends State<FlutterLogin>
    with TickerProviderStateMixin {
  final GlobalKey<AuthCardState> authCardKey = GlobalKey();
  static const loadingDuration = const Duration(milliseconds: 400);
  AnimationController _loadingController;
  AnimationController _logoController;
  AnimationController _titleController;
  double _selectTimeDilation = 1.0;

  @override
  void initState() {
    super.initState();

    _loadingController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    )..addStatusListener((status) {
        if (status == AnimationStatus.forward) {
          _logoController.forward();
          _titleController.forward();
        }
        if (status == AnimationStatus.reverse) {
          _logoController.reverse();
          _titleController.reverse();
        }
      });
    _logoController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );
    _titleController = AnimationController(
      vsync: this,
      duration: loadingDuration,
    );

    Future.delayed(const Duration(seconds: 1), () {
      _loadingController.forward();
    });
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _logoController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _reverseHeaderAnimation() {
    if (widget.logoTag == null) {
      _logoController.reverse();
    }
    if (widget.titleTag == null) {
      _titleController.reverse();
    }
  }

  Widget _buildHeader(double height, LoginTheme loginTheme) {
    return _Header(
      logoController: _logoController,
      titleController: _titleController,
      height: height,
      logoPath: widget.logo,
      logoTag: widget.logoTag,
      title: widget.title,
      titleTag: widget.titleTag,
      loginTheme: loginTheme,
    );
  }

  /// 调试按钮
  Widget _buildDebugAnimationButtons() {
    print("_buildDebugAnimationButtons");
    const textStyle = TextStyle(fontSize: 12, color: Colors.white);

    return Positioned(
      bottom: 0,
      right: 0,
      child: Row(
        key: kDebugToolbarKey,
        children: <Widget>[
          RaisedButton(
            color: Colors.green,
            child: Text('OPTIONS', style: textStyle),
            onPressed: () {
              timeDilation = 1.0;

              showModalBottomSheet(
                context: context,
                builder: (_) {
                  return _AnimationTimeDilationDropdown(
                    initialValue: _selectTimeDilation,
                    onChanged: (int index) {
                      setState(() {
                        _selectTimeDilation = _AnimationTimeDilationDropdown
                            .animationSpeeds[index]
                            .toDouble();
                      });
                    },
                  );
                },
              ).then((_) {
                // wait until the BottomSheet close animation finishing before
                // assigning or you will have to watch x100 time slower animation
                Future.delayed(const Duration(milliseconds: 300), () {
                  timeDilation = _selectTimeDilation;
                });
              });
            },
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.blue,
            child: Text('LOADING', style: textStyle),
            onPressed: () => authCardKey.currentState.runLoadingAnimation(),
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.orange,
            child: Text('PAGE', style: textStyle),
            onPressed: () => authCardKey.currentState.runChangePageAnimation(),
          ),
          RaisedButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: Colors.red,
            child: Text('NAV', style: textStyle),
            onPressed: () => authCardKey.currentState.runChangeRouteAnimation(),
          ),
        ],
      ),
    );
  }

  ThemeData _mergeTheme({ThemeData theme, LoginTheme loginTheme}) {
    final originalPrimaryColor = loginTheme.primaryColor ?? theme.primaryColor;
    final primaryDarkShades = getDarkShades(originalPrimaryColor);
    final primaryColor = primaryDarkShades.length == 1
        ? lighten(primaryDarkShades.first)
        : primaryDarkShades.first;
    final primaryColorDark = primaryDarkShades.length >= 3
        ? primaryDarkShades[2]
        : primaryDarkShades.last;
    final accentColor = loginTheme.accentColor ?? theme.accentColor;
    final errorColor = loginTheme.errorColor ?? theme.errorColor;
    // the background is a dark gradient, force to use white text if detect default black text color
    final isDefaultBlackText = theme.textTheme.display2.color ==
        Typography.blackMountainView.display2.color;
    final titleStyle = theme.textTheme.display2
        .copyWith(
          color: loginTheme.accentColor ??
              (isDefaultBlackText
                  ? Colors.white
                  : theme.textTheme.display2.color),
          fontSize: loginTheme.beforeHeroFontSize,
          fontWeight: FontWeight.w300,
        )
        .merge(loginTheme.titleStyle);
    final textStyle = theme.textTheme.body1
        .copyWith(color: Colors.black54)
        .merge(loginTheme.bodyStyle);
    final textFieldStyle = theme.textTheme.subhead
        .copyWith(color: Colors.black.withOpacity(.65), fontSize: 14)
        .merge(loginTheme.textFieldStyle);
    final buttonStyle = theme.textTheme.button
        .copyWith(color: Colors.white)
        .merge(loginTheme.buttonStyle);
    final cardTheme = loginTheme.cardTheme;
    final inputTheme = loginTheme.inputTheme;
    final buttonTheme = loginTheme.buttonTheme;
    final roundBorderRadius = BorderRadius.circular(100);

    LoginThemeHelper.loginTextStyle = titleStyle;

    return theme.copyWith(
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      accentColor: accentColor,
      errorColor: errorColor,
      cardTheme: theme.cardTheme.copyWith(
        clipBehavior: cardTheme.clipBehavior,
        color: cardTheme.color ?? theme.cardColor,
        elevation: cardTheme.elevation ?? 12.0,
        margin: cardTheme.margin ?? const EdgeInsets.all(4.0),
        shape: cardTheme.shape ??
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      ),
      inputDecorationTheme: theme.inputDecorationTheme.copyWith(
        filled: inputTheme.filled,
        fillColor: inputTheme.fillColor ??
            Color.alphaBlend(
              primaryColor.withOpacity(.07),
              Colors.grey.withOpacity(.04),
            ),
        contentPadding: inputTheme.contentPadding ??
            const EdgeInsets.symmetric(vertical: 4.0),
        errorStyle: inputTheme.errorStyle ?? TextStyle(color: errorColor),
        labelStyle: inputTheme.labelStyle,
        enabledBorder: inputTheme.enabledBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent),
              borderRadius: roundBorderRadius,
            ),
        focusedBorder: inputTheme.focusedBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        errorBorder: inputTheme.errorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor),
              borderRadius: roundBorderRadius,
            ),
        focusedErrorBorder: inputTheme.focusedErrorBorder ??
            inputTheme.border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: errorColor, width: 1.5),
              borderRadius: roundBorderRadius,
            ),
        disabledBorder: inputTheme.disabledBorder ?? inputTheme.border,
      ),
      floatingActionButtonTheme: theme.floatingActionButtonTheme.copyWith(
        backgroundColor: buttonTheme?.backgroundColor ?? primaryColor,
        splashColor: buttonTheme.splashColor ?? theme.accentColor,
        elevation: buttonTheme.elevation ?? 4.0,
        highlightElevation: buttonTheme.highlightElevation ?? 2.0,
        shape: buttonTheme.shape ?? StadiumBorder(),
      ),
      // put it here because floatingActionButtonTheme doesnt have highlightColor property
      highlightColor:
          loginTheme.buttonTheme.highlightColor ?? theme.highlightColor,
      textTheme: theme.textTheme.copyWith(
        display2: titleStyle,
        body1: textStyle,
        subhead: textFieldStyle,
        button: buttonStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginTheme = widget.theme ?? LoginTheme();
    final theme = _mergeTheme(theme: Theme.of(context), loginTheme: loginTheme);
    final deviceSize = MediaQuery.of(context).size;
    const headerMargin = 15;
    const cardInitialHeight = 300;
    final cardTopPosition = deviceSize.height / 2 - cardInitialHeight / 2;
    final headerHeight = cardTopPosition - headerMargin;
    final emailValidator =
        widget.emailValidator ?? FlutterLogin.defaultEmailValidator;
    final passwordValidator =
        widget.passwordValidator ?? FlutterLogin.defaultPasswordValidator;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: widget.messages ?? LoginMessages(),
        ),
        ChangeNotifierProvider(
          create: (context) => Auth(
            onLogin: widget.onLogin,
            onSignup: widget.onSignup,
            onRecoverPassword: widget.onRecoverPassword,
          ),
        ),
      ],
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        body: Stack(
          children: <Widget>[
            widget.background ??
                GradientBox(
                  colors: [
                    loginTheme.pageColorLight ?? theme.primaryColor,
                    loginTheme.pageColorDark ?? theme.primaryColorDark,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Theme(
                data: theme,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Positioned(
                      child: AuthCard(
                        key: authCardKey,
                        padding: EdgeInsets.only(top: cardTopPosition),
                        loadingController: _loadingController,
                        emailValidator: emailValidator,
                        passwordValidator: passwordValidator,
                        onSubmit: _reverseHeaderAnimation,
                        onSignPressed: widget.onSignBtnPressed,
                        onForgotPressed: widget.onForgotBtnPressed,
                        onSubmitCompleted: widget.onSubmitAnimationCompleted,
                      ),
                    ),
                    Positioned(
                      top: cardTopPosition - headerHeight - headerMargin,
                      child: _buildHeader(headerHeight, loginTheme),
                    ),
                  ],
                ),
              ),
            ),
// TODO: debug off
//            if (!kReleaseMode && widget.showDebugButtons)
//              _buildDebugAnimationButtons(),
          ],
        ),
      ),
    );
  }
}
