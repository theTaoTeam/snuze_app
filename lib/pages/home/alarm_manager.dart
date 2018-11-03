import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:snuze/scoped-models/main.dart';

import './alarm_settings.dart';
import './home_nav.dart';
import './time_picker/main.dart';

class AlarmManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 400.0 : deviceWidth * 0.65;
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        children: <Widget>[
          ScopedModelDescendant<MainModel>(
            builder: (context, child, model) {
              return TimePicker(alarm: model.alarm);
            }
          ),
          AlarmSettings(),
          SizedBox(),
          HomeNav(targetWidth),
        ],
      ),
    );
  }
}
