import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:snuze/scoped-models/main.dart';


class SnuzePage extends StatelessWidget {
  Container _buildHeaderSection(String alarmTime, String snuzeAmount) {
    return Container(
      child: Column(
        children: <Widget>[
          Text(
            alarmTime,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Montserrat',
            ),
          ),
          Text(
            snuzeAmount,
            style: TextStyle(
              fontSize: 20,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }

  Container _buildCancelFooterSection(BuildContext context, Function onAlarmToggleChange) {
    return Container(
        child: Column(
      children: <Widget>[
        Text(
          "keep the app open",
          style: TextStyle(
            fontSize: 20,
            fontFamily: 'Montserrat',
          ),
        ),
        OutlineButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          color: Color.fromRGBO(255, 255, 255, 0),
          textColor: Colors.white,
          splashColor: Color(0xFFFE355A),
          highlightColor: Colors.transparent,
          highlightedBorderColor: Colors.transparent,
          highlightElevation: 3,
          child: Text(
            "cancel",
            style: TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
          ),
          onPressed: () {
            print("cancel pressed");
            onAlarmToggleChange(<String, dynamic>{"isActive": false});
            Navigator.pushNamed(context, '/home');
          },
        ),
      ],
    ));
  }

  Container _buildSnuzeStopFooterSection(BuildContext context, Function onSnuze, Function onStop, double snuzeAmount) {
    return Container(
      child: Column(
        children: <Widget>[
          OutlineButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            color: Color.fromRGBO(255, 255, 255, 0),
            textColor: Colors.white,
            splashColor: Color(0xFFFE355A),
            highlightColor: Colors.transparent,
            highlightedBorderColor: Colors.transparent,
            highlightElevation: 3,
            child: Text(
              "snuze",
              style: TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
            ),
            onPressed: () {
              print("snuze pressed");
              onSnuze(snuzeAmount: snuzeAmount);
            },
          ),
          OutlineButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            color: Color.fromRGBO(255, 255, 255, 0),
            textColor: Colors.white,
            splashColor: Color(0xFFFE355A),
            highlightColor: Colors.transparent,
            highlightedBorderColor: Colors.transparent,
            highlightElevation: 3,
            child: Text(
              "stop",
              style: TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
            ),
            onPressed: () {
              print("stop pressed");
              onStop();
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [
                  0,
                  0.58,
                  1,
                ],
                colors: [
                  Color(0xFFFE2562),
                  Color(0xFFFE355A),
                  Color(0xFFFFB52E),
                ]),
          ),
          child: Center(
            child: Column(
              children: <Widget>[
                _buildHeaderSection(model.alarmTimeToString(), model.snuzeAmountToString()),
                Container(
                  width: targetWidth,
                  // height: 40,
                  child: model.isAlarmTriggered()
                      ? _buildSnuzeStopFooterSection(context, model.createSnuze, model.handleStop, model.alarm.snuzeAmount)
                      : _buildCancelFooterSection(context, model.updateAlarm)
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),
      );
    });
  }
}
