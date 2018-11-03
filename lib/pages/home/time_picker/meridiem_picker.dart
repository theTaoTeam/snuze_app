import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MeridiemPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: CupertinoPicker(
        onSelectedItemChanged: (int newValue) {
          print(newValue);
        },
        itemExtent: 30.0,
        children: [
          Text("AM"),
          Text("PM")
        ]
      ),
    );
  }
}