import 'package:flutter/material.dart';

class AlarmSettings extends StatefulWidget {
  @override
    State<StatefulWidget> createState() {
      // TODO: implement createState
      return _AlarmSettingsState();
    }
}

class _AlarmSettingsState extends State<AlarmSettings>{
  double _sliderValue = 10.00;
  bool _alarmSet = true;

    Widget _buildDonationSlider(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text('\$' + _sliderValue.toString()),
              Slider(
                value: _sliderValue,
                activeColor: Theme.of(context).accentColor,
                min: 0.25,
                max: 25.0,
                divisions: 10,
                onChanged: (double newValue) {
                  setState(() {
                    _sliderValue = newValue;
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

  Widget _buildAlarmToggle(BuildContext context) {
    return SwitchListTile(
      value: _alarmSet,
      onChanged: (bool value) {
        print(value);
        setState(() {
          _alarmSet = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Expanded(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildDonationSlider(context),
            _buildAlarmToggle(context),
          ],
        ),
      ),
    );
  }
}
