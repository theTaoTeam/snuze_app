import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:snuze/scoped-models/main.dart';

import './hour_picker.dart';
import './minute_picker.dart';
import './meridiem_picker.dart';

class TimePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
          child: new Row(
            children: <Widget>[
              HourPicker(
                hour: model.alarm.hour,
                onHourChange: model.updateAlarm
              ),
              MinutePicker(
                minute: model.alarm.minute,
                onMinuteChange: model.updateAlarm
              ),
              MeridiemPicker(
                meridiem: model.alarm.meridiem,
                onMeridiemChange: model.updateAlarm
              )
            ],
            mainAxisSize: MainAxisSize.min,
          ),
          height: MediaQuery.of(context).size.height / 3,
        );
      }
    );
  }
}
