import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:scoped_model/scoped_model.dart';
import 'package:snuze/scoped-models/main.dart';

import 'package:snuze/helpers/time_picker.dart';

class HourPicker extends StatelessWidget {
  // final FixedExtentScrollController scrollController = FixedExtentScrollController(initialItem: hour);
  final int hour;
  final Function onHourChange;
  HourPicker({this.hour, this.onHourChange});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (context, child, model) {
        return Flexible(
          fit: FlexFit.loose,
          child: CupertinoPicker(
            onSelectedItemChanged: (int newValue) {
              print(newValue);
              onHourChange(<String,dynamic>{
                "hour": newValue
              });
            },
            itemExtent: 30.0,
            children: numberTextList(), // defaults to 1-12,
            looping: false,
          ),
        );
      }
    );
  }
}