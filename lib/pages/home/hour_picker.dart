import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HourPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: CupertinoPicker(
        onSelectedItemChanged: (int newValue) {
          print(newValue);
        },
        itemExtent: 30.0,
        children: <Widget>[
          Text("01"),
          Text("02"),
          Text("03"),
          Text("04"),
          Text("05"),
          Text("06"),
          Text("07"),
          Text("08"),
          Text("09"),
          Text("10"),
          Text("11"),
          Text("12"),
        ]
      ),
    );
  }
}