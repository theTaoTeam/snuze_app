import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../helpers/time_picker.dart';

class MinutePicker extends StatelessWidget {
  final int minute;
  final Function onMinuteChange;
  MinutePicker({this.minute, this.onMinuteChange});

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController = FixedExtentScrollController(initialItem: this.minute);
    return Flexible(
      fit: FlexFit.loose,
      child: CupertinoPicker(
        onSelectedItemChanged: (int newValue) {
          onMinuteChange(<String, dynamic>{"minute": newValue});
        },
        itemExtent: 30.0,
        children: numberTextList(start: 0, end: 59, inc: 1),
        scrollController: scrollController,
      ),
    );
  }
}