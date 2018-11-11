import 'package:flutter/material.dart';
import 'dart:math';

import 'package:snuze/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class AlarmSettings extends StatelessWidget {

  Widget _buildDonationSlider(BuildContext context, double snuzeAmount, Function onSnuzeAmountChange) {
    final double _sliderValue = snuzeAmount;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('\$${_sliderValue.toStringAsFixed(2)}'),
              Slider(
                value: _sliderValue,
                activeColor: Theme.of(context).accentColor,
                min: 0.25,
                max: 25.00,
                divisions: 99,
                onChanged: (double newValue) {
                  int decimalPlaces = 2;
                  int fac = pow(10, decimalPlaces);
                  newValue = (newValue * fac).round() / fac;
                  print(newValue);
                  onSnuzeAmountChange(<String, dynamic>{
                    "snuzeAmount": newValue,
                  });
                },
                onChangeStart: (double startValue) {
                  print('Started change at $startValue');
                },
                onChangeEnd: (double endValue) {
                  print('Ended change at $endValue');
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAlarmToggle(BuildContext context, bool isActive, Function onAlarmToggleChange) {
    final bool _alarmSet = isActive;
    return SwitchListTile(
      value: _alarmSet,
      onChanged: (bool newValue) {
        print(newValue);
        onAlarmToggleChange(<String, dynamic>{
          "isActive": newValue
        });
      },
    );
  }

  @override
  
  Widget build(BuildContext context) {
    return ScopedModelDescendant<MainModel>(
      builder: (BuildContext context, Widget child, MainModel model) {
        return Container(
          child: Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _buildDonationSlider(context, model.alarm.snuzeAmount, model.updateAlarm),
                _buildAlarmToggle(context, model.alarm.isActive, model.updateAlarm),
              ],
            ),
          ),
        );
      }
    );
  }
}