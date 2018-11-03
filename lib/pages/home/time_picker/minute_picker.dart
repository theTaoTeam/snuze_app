import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../helpers/time_picker.dart';

class MinutePicker extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: CupertinoPicker(
        onSelectedItemChanged: (int newValue) {
          print(newValue);
        },
        itemExtent: 30.0,
        children: numberTextList(start: 0, end: 59, inc: 5)
      ),
    );
  }
}