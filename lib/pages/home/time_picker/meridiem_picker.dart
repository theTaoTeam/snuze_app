import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class MeridiemPicker extends StatelessWidget {
  final int meridiem;
  final Function onMeridiemChange;
  MeridiemPicker({this.meridiem, this.onMeridiemChange});

  @override
  Widget build(BuildContext context) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: this.meridiem);
    return Flexible(
      fit: FlexFit.loose,
      child: CupertinoPicker(
        backgroundColor: Colors.transparent,
        onSelectedItemChanged: (int newValue) {
          onMeridiemChange(<String, dynamic>{"meridiem": newValue});
        },
        itemExtent: 30.0,
        children: [Text("AM"), Text("PM")],
        scrollController: scrollController,
      ),
    );
  }
}
