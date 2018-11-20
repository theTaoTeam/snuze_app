import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:snuze/styles/themes/themes.dart';

// import "package:snuze/models/alarm.dart";
import 'package:snuze/scoped-models/main.dart';

import 'package:snuze/pages/home/main.dart';
import 'package:snuze/pages/auth/auth.dart';
import 'package:snuze/pages/auth/signup.dart';
import 'package:snuze/pages/auth/forgot_password.dart';
import 'package:snuze/pages/settings/settings.dart';

void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;
  bool _darkTheme = false;
  @override
  void initState() {
    // _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      print('User subject change: $isAuthenticated');
      //used to listen for different auth states. boolean
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });

    _model.themeSubject.listen((bool newTheme) {
      print('in listener | theme: $newTheme');
      setState(() {
        _darkTheme = newTheme;
      });
    });
    _model.fetchAlarm();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = _darkTheme;
    print('DARK THEME --> $darkTheme');
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: darkTheme ? buildDarkTheme() : buildLightTheme(),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : MainPage(_model),
          '/signup': (BuildContext context) => SignUpPage(),
          '/forgotpassword': (BuildContext context) => ForgotPasswordPage(),
          '/home': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : MainPage(_model),
          '/settings': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : SettingsPage(model: _model),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => MainPage(_model),
          );
        },
      ),
    );
  }
}
