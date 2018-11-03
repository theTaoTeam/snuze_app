import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import './alarm_manager.dart';
import '../../scoped-models/main.dart';


class MainPage extends StatefulWidget {
  final MainModel model;

  MainPage(this.model);
  @override
    State<StatefulWidget> createState() {
      return _MainPageState();
    }
}
class _MainPageState extends State<MainPage> {
  // @override
  // initState() {
  //   widget.model.fetchUserAlarm();
  //   super.initState();
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Snüze',
        ),
        centerTitle: true,
      ),
      body: AlarmManager(),
    );
  }
}
