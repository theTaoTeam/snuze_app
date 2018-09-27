import 'package:flutter/material.dart';

class TimePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Clock',
            ),
          ],
        ),
      ),
    );
  }
}
