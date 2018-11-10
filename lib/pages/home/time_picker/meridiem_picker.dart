import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MeridiemPicker extends StatelessWidget {
  final int meridiem;
  final Function onMeridiemChange;
  MeridiemPicker({this.meridiem, this.onMeridiemChange});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.loose,
      child: CupertinoPicker(
        onSelectedItemChanged: (int newValue) {
          onMeridiemChange(<String, dynamic>{"meridiem": newValue});
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