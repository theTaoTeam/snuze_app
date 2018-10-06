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
          Text("1"),
          Text("2"),
          Text("3"),
          Text("4"),
          Text("5"),
          Text("6"),
          Text("7"),
          Text("8"),
          Text("9"),
          Text("10"),
          Text("11"),
          Text("12"),
        ]
      ),
    );
  }
}