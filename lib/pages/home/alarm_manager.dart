import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// import 'package:scoped_model/scoped_model.dart';
// import 'package:snuze/scoped-models/main.dart';

import './alarm_settings.dart';
import './home_nav.dart';
import './time_picker/main.dart';

class AlarmManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double _targetWidth = deviceWidth > 550.0 ? 400.0 : deviceWidth * 0.65;
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          TimePicker(targetWidth: _targetWidth,),
          AlarmSettings(targetWidth: _targetWidth,),
          SizedBox(),
          HomeNav(targetWidth: _targetWidth,),
        ],
      ),
    );
  }
}