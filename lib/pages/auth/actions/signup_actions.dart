import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:snuze/scoped-models/main.dart';

class SignUpActionButton extends StatelessWidget {
  final Function submitForm;

  SignUpActionButton({this.submitForm});

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return !model.isLoading
          ? Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Container(
                  width: targetWidth,
                  height: 40,
                  child: RaisedButton(
                    highlightElevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    textColor: Colors.red,
                    color: Colors.white,
                    splashColor: Color(0xFFFE2562),
                    child: Text(
                      'get snuzing',
                      style: TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
                    ),
                    onPressed: () => submitForm(model.register),
                  ),
                ),
              ],
            )
          : Column(children: <Widget>[
            SizedBox(
                  height: 20,
                ),
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              SizedBox(
                height: 15,
              )
            ]);
    });
  }
}
