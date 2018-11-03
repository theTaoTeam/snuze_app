import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../../../helpers/time_picker.dart';

class HourPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: CupertinoPicker(
        onSelectedItemChanged: (int newValue) {
          print(newValue);
        },
        itemExtent: 30.0,
        children: numberTextList() // defaults to 1-12,
      ),
    );
  }
}