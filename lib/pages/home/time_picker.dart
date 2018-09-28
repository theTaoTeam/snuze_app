import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class TimePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: CupertinoTimerPicker(
        mode: CupertinoTimerPickerMode.hm,
        initialTimerDuration: Duration(),
        onTimerDurationChanged: (Duration duration) {
          print(duration);
        },
      ),
    );
  }
}
