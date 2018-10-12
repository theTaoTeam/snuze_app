import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';

import 'package:scoped_model/scoped_model.dart';

import './scoped-models/main.dart';

import './pages/home/main.dart';
import './pages/auth/auth.dart';

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
  @override
  Widget build(BuildContext context) {
    final MainModel model = MainModel();
    return ScopedModel<MainModel>(
      model: model,
      child: MaterialApp(
        theme: ThemeData(
          backgroundColor: Colors.white,
          brightness: Brightness.light,
          primaryColor: Colors.white,
          accentColor: Colors.red,
        ),
        routes: {
          '/': (BuildContext context) => AuthPage(),
          '/home': (BuildContext context) => MainPage(),
        },
        onUnknownRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (BuildContext context) => MainPage(),
          );
        },
      ),
    );
  }
}
