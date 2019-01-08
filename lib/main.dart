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
import 'package:snuze/pages/snuze/snuze.dart';
import 'package:snuze/pages/sounds/sounds.dart';
import 'package:snuze/pages/mysnuze/mysnuze.dart';


void main() {
  // debugPaintSizeEnabled = true;
  // debugPaintBaselinesEnabled = true;
  // debugPaintPointersEnabled = true;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MainModel _model = new MainModel();
    _model.fetchUser();
    _model.fetchAlarm();
    bool _darkTheme = false;
    return ScopedModel<MainModel>(
      model: _model,
      child: _buildApp(context, _darkTheme)
    );
  }
}

Widget _buildHomePage(model) {
  if(model.alarm.isActive) {
    return SnuzePage();
  } else {
    return MainPage(model);
  }
}

Widget _buildApp (BuildContext context, bool darkTheme) {
  return ScopedModelDescendant<MainModel>(
    builder: (BuildContext context, Widget child, MainModel model) {
      return MaterialApp(
        theme: darkTheme ? buildDarkTheme() : buildLightTheme(),
        routes: {
          '/': (BuildContext context) =>
              model.currentUser == null ? AuthPage() : _buildHomePage(model),
          '/signup': (BuildContext context) => SignUpPage(),
          '/forgotpassword': (BuildContext context) => ForgotPasswordPage(),
          '/home': (BuildContext context) =>
              model.currentUser == null ? AuthPage() : MainPage(model),
          '/settings': (BuildContext context) =>
              model.currentUser == null ? AuthPage() : SettingsPage(model: model),
          '/sounds': (BuildContext context) => SoundsPage(),
          '/mysnuze': (BuildContext context) => MySnuzePage(),

        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => MainPage(model),
          );
        },
      );
    }
  );
}