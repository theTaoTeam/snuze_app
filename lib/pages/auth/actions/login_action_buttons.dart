import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import 'package:snuze/scoped-models/main.dart';

class LoginActionButtons extends StatelessWidget {
  final Function submitForm;
  final Function updateForgotPassword;

  LoginActionButtons({this.submitForm, this.updateForgotPassword});

  void _navigateToSignUpPage(BuildContext context) {
    Navigator.pushNamed(context, '/signup');
  }

  void _navigateToForgotPasswordPage(BuildContext context) async {
    final result = await Navigator.pushNamed(context, '/forgotpassword');
    if (result != null) {
      updateForgotPassword(false, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return !model.isLoading
          ? Column(
              children: <Widget>[
                Container(
                  width: targetWidth,
                  height: 40,
                  child: RaisedButton(
                      highlightElevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      textColor: Color(0xFFFE2562),
                      color: Colors.white,
                      splashColor: Color(0xFFFE355A),
                      highlightColor: Colors.transparent,
                      child: Text(
                        'login',
                        style:
                            TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
                      ),
                      onPressed: () {
                        submitForm(model.login);
                      }),
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  width: targetWidth,
                  height: 40,
                  child: OutlineButton(
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
                      'create an account',
                      style: TextStyle(fontSize: 20, fontFamily: 'Montserrat'),
                    ),
                    onPressed: () {
                      _navigateToSignUpPage(context);
                    },
                  ),
                ),
                FlatButton(
                  textColor: Colors.white,
                  highlightColor: Colors.transparent,
                  child: Text(
                    'forgot password?',
                    style: TextStyle(fontSize: 17, fontFamily: 'Montserrat'),
                  ),
                  onPressed: () {
                    print('Forgot Password pressed!');
                    _navigateToForgotPasswordPage(context);
                  },
                ),
              ],
            )
          : Column(children: <Widget>[
              CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              SizedBox(
                height: 5,
              )
            ]);
    });
  }
}
