import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:snuze/helpers/exceptions.dart';

import 'package:snuze/scoped-models/main.dart';
import 'package:snuze/pages/auth/actions/login_action_buttons.dart';

class AuthPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthPageState();
  }
}

class _AuthPageState extends State<AuthPage> {
  final Map<String, dynamic> _formData = {
    'email': null,
    'password': null,
  };
  Map<String, dynamic> cardInfo = {
    'number': '4242424242424242',
    'expMonth': 11,
    'expYear': 2020,
    'cvc': '123',
  };
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  bool _forgotPasswordEmailSent = false;
  String _forgotPasswordMessage;

  Widget _buildTitleText(double targetWidth) {
    return Container(
        // width: targetWidth - 100,
        child: Text(
      "snüze",
      style: TextStyle(
          color: Colors.white,
          fontSize: Platform.isAndroid ? 110 : 90,
          fontWeight: FontWeight.w900,
          fontFamily: 'Montserrat-bold'),
      textAlign: TextAlign.center,
    ));
  }

  Widget _buildEmailTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'email',
        labelStyle: new TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(255, 255, 255, 0.2),
        errorStyle: TextStyle(color: Colors.white),
      ),
      style: new TextStyle(height: .3, fontFamily: 'Montserrat'),
      keyboardType: TextInputType.emailAddress,
      validator: (String value) {
        // print('Clamptron@Gmail.com'.toLowerCase());
        final String newVal = value.toLowerCase();
        if (newVal.isEmpty ||
            !RegExp(r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
                .hasMatch(newVal.trim())) {
          return 'Double check your email';
        }
      },
      onSaved: (String value) {
        final String newVal = value.toLowerCase().trim();
        _formData['email'] = newVal;
      },
    );
  }

  Widget _buildPasswordTextField() {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'password',
        labelStyle: new TextStyle(color: Colors.white),
        filled: true,
        fillColor: Color.fromRGBO(255, 255, 255, 0.2),
        errorStyle: TextStyle(color: Colors.white),
      ),
      style: new TextStyle(height: .3, fontFamily: 'Montserrat'),
      obscureText: true,
      controller: _passwordTextController,
      validator: (String value) {
        if (value.isEmpty || value.trim().length < 6) {
          return 'Double check your password';
        }
      },
      onSaved: (String value) {
        _formData['password'] = value.trim();
      },
    );
  }

  void submitForm(Function login) async {
    if (!_formKey.currentState.validate()) {
      return;
    }
    _formKey.currentState.save();
    try {
      await login(email: _formData['email'], password: _formData['password']);
      Navigator.pushReplacementNamed(context, '/');
    } on CausedException catch (exc) {
      exc.debugPrint();
      _showErrorDialog(context: context, userMessage: exc.userMessage);
    } catch (e) {
      _showErrorDialog(
          context: context,
          userMessage: "Something went wrong, please try again!");
    }
  }

  void _showErrorDialog({BuildContext context, String userMessage}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Oops!'),
          content: Text(userMessage),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void updateForgotPassword(bool boolean, Object result) {
    setState(() {
      _forgotPasswordEmailSent = true;
      _forgotPasswordMessage = result;
    });
    Timer(Duration(seconds: 5), () {
      setState(() {
        _forgotPasswordEmailSent = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
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
        padding: EdgeInsets.fromLTRB(30, 30, 30, 50),
        child: Center(
          child: SingleChildScrollView(
            reverse: true,
            child: Container(
                margin: new EdgeInsets.fromLTRB(0, 50, 0, 0),
                width: targetWidth,
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        _buildTitleText(targetWidth),
                        SizedBox(
                          height: 40,
                        ),
                        _forgotPasswordEmailSent
                            ? Text(
                                _forgotPasswordMessage,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat'),
                              )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        _buildEmailTextField(),
                        SizedBox(
                          height: 10.0,
                        ),
                        _buildPasswordTextField(),
                        SizedBox(
                          height: 30.0,
                          child: Center(
                            child: Container(
                              height: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        LoginActionButtons(
                            submitForm: submitForm,
                            updateForgotPassword: updateForgotPassword),
                      ],
                    ))),
          ),
        ),
      ),
    );
  }
}
