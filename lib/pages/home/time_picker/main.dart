import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:snuze/models/alarm.dart';

import './hour_picker.dart';
import './minute_picker.dart';
import './meridiem_picker.dart';

class TimePicker extends StatelessWidget {
  final Alarm alarm;
  TimePicker({this.alarm});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new Row(
        children: <Widget>[
          HourPicker(hour: alarm.hour),
          MinutePicker(),
          MeridiemPicker()
        ],
        mainAxisSize: MainAxisSize.min,
      ),
      height: MediaQuery.of(context).size.height / 3,
    );
  }
}
