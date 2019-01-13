import 'package:flutter/material.dart';

import 'package:snuze/helpers/alarm_settings.dart';
import 'package:snuze/scoped-models/main.dart';
import 'package:scoped_model/scoped_model.dart';

class AlarmSettings extends StatelessWidget {
  final double targetWidth;

  AlarmSettings({this.targetWidth});

  Widget _buildDonationSlider(
      BuildContext context, double snuzeAmount, Function onSnuzeAmountChange) {
    final double _sliderValue = snuzeAmount;
    return Container(
      width: targetWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text('\$${toPrice(_sliderValue).toStringAsFixed(2)}'),
              Container(
                child: Slider(
                  value: _sliderValue,
                  activeColor: Theme.of(context).accentColor,
                  min: 0.00,
                  max: 39.00,
                  divisions: 39,
                  onChanged: (double newValue) {
                    newValue = decimalPrecision(number: newValue);
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
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAlarmToggle(
      BuildContext context, bool isActive, Function onAlarmToggleChange) {
    final bool _alarmSet = isActive;
    return SwitchListTile(
      value: _alarmSet,
      onChanged: (bool newValue) {
        onAlarmToggleChange();
        if(newValue) {
          Navigator.pushNamed(context, '/');
        }
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
              _buildDonationSlider(
                  context, model.alarm.snuzeAmount, model.updateAlarm),
               _buildAlarmToggle(
                    context, model.alarm.isActive, model.setAlarm),
              
            ],
          ),
        ),
      );
    });
  }
}
