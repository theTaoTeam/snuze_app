import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';

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
    // TODO: implement createState
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  final MainModel _model = MainModel();
  bool _isAuthenticated = false;
  @override
  void initState() {
    // _model.autoAuthenticate();
    _model.userSubject.listen((bool isAuthenticated) {
      //used to listen for different auth states. boolean
      setState(() {
        _isAuthenticated = isAuthenticated;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModel<MainModel>(
      model: _model,
      child: MaterialApp(
        theme: ThemeData(
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          primaryColor: Colors.white,
          accentColor: Colors.red,
        ),
        routes: {
          // '/': (BuildContext context) =>
          //     !_isAuthenticated ? AuthPage() : MainPage(_model),
          '/': (BuildContext context) =>
              SettingsPage(),
          '/signup': (BuildContext context) =>
              SignUpPage(),
          '/home': (BuildContext context) => MainPage(_model),
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
