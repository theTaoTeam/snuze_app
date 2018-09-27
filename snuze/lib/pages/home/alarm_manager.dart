import 'package:flutter/material.dart';

import './time_picker.dart';
import './alarm_settings.dart';
import './home_nav.dart';

class AlarmManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 400.0 : deviceWidth * 0.65;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        children: <Widget>[
          TimePicker(),
          AlarmSettings(),
          SizedBox(),
          HomeNav(targetWidth),
        ],
      ),
    );
  }
}
