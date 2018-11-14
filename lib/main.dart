import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snuze/styles/themes/themes.dart';

import './scoped-models/main.dart';

import 'package:snuze/pages/home/main.dart';
import 'package:snuze/pages/auth/auth.dart';
import 'package:snuze/pages/auth/signup.dart';
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
    _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = _darkTheme;
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: darkTheme ? buildDarkTheme() : buildLightTheme(),
        routes: {
          '/': (BuildContext context) =>
              !_isAuthenticated ? AuthPage() : MainPage(_model),
          // '/': (BuildContext context) =>
          //     !_isAuthenticated ? AuthPage() : SettingsPage(model: _model),
          '/signup': (BuildContext context) => SignUpPage(),
          '/home': (BuildContext context) => MainPage(_model),
          '/settings': (BuildContext context) => SettingsPage(model: _model),
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
