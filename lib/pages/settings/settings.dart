import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';

import 'package:scoped_model/scoped_model.dart';

import 'package:snuze/pages/settings/update_payment_form.dart';
import 'package:snuze/scoped-models/main.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final MainModel _model = new MainModel();
  bool _sentPassword = false;
  Map<String, dynamic> userSettings = {
    'email': 'clamptron@gmail.com',
    'darkTheme': false,
  };
  Map<String, dynamic> _newCardInfo = {
    'number': '',
    'expMonth': null,
    'expYear': null,
    'cvc': '',
  };
  @override
  void initState() {
    // _fetchUserSettings();
    super.initState();
  }

  void _fetchUserSettings() async {
    final storedUserSettings = await _model.fetchUserSettings();
    print(storedUserSettings);
    setState(() {
      storedUserSettings.forEach((key, val) {
        if (userSettings[key] == null) {
          userSettings[key] = false;
        } else {
          userSettings[key] = val;
        }
      });
    });
    print('settings: $userSettings');
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
            color: Color(0xFF434343),
            fontSize: 23,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildDarkThemeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: Text(
            'dark theme',
            style: TextStyle(fontSize: 15),
          ),
        ),
        Container(
          child: CupertinoSwitch(
            value: userSettings['darkTheme'],
            activeColor: Color(0xFFFE2562),
            onChanged: (bool val) {
              print(val);
              setState(() {
                userSettings['darkTheme'] = !userSettings['darkTheme'];
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Container(
          child: Text('email'),
        ),
        Container(
          width: 200,
          child: TextField(
            decoration: InputDecoration(
              labelText: userSettings['email'],
              border: InputBorder.none,
            ),
            onChanged: (String val) {
              setState(() {
                userSettings['email'] = val;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(double targetWidth, bool isFullWidth) {
    return SizedBox(
      width: targetWidth,
      height: 20.0,
      child: Center(
        child: Container(
          margin: isFullWidth ? EdgeInsets.all(0) : EdgeInsets.only(left: 80),
          height: 1,
          color: Color(0xFFA1A1A1),
        ),
      ),
    );
  }

  Widget _buildActionButton(String action) {
    return action == 'reset'
        ? FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Text(
              'reset password?',
            ),
            textColor: Color(0xFFFE2562),
            onPressed: () {
              print('pressed reset password');
              _model.resetPassword(userSettings['email']);
              setState(() {
                _sentPassword = true;
              });
              Timer(Duration(seconds: 5), () {
                setState(() {
                  _sentPassword = false;
                });
              });
            },
          )
        : FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Text(
              'update card info',
            ),
            textColor: Color(0xFFFE2562),
            onPressed: () {
              print('update card info pressed');
            },
          );
  }

  void updateCardInfo(Map<String, dynamic> ccInfo) {
    ccInfo.forEach((key, value) {
      setState(() {
        _newCardInfo[key] = value;
      });
    });
    print(_newCardInfo);
  }

  void _saveSettings() {
    _model.saveUserSettings(userSettings);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return ScopedModelDescendant<MainModel>(
        builder: (BuildContext context, Widget child, MainModel model) {
      return Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        appBar: AppBar(
          title: Text(
            'settings',
            style: TextStyle(fontSize: 23),
          ),
          centerTitle: true,
          elevation: 0.0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(
            color: Colors.white, //change your color here
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'done',
                style: TextStyle(fontSize: 15),
              ),
              textColor: Color(0xFFFE2562),
              onPressed: () {
                print('save setting pressed');
                _saveSettings();
              },
            )
          ],
        ),
        body: Center(
          child: SingleChildScrollView(
            reverse: true,
            child: Container(
              width: targetWidth,
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        child: _buildDarkThemeRow(),
                      ),
                      _buildDivider(targetWidth, false),
                      Container(
                        child: _buildEmailRow(),
                      ),
                      _buildDivider(targetWidth, false),
                      Center(
                          child: _sentPassword
                              ? AnimatedOpacity(
                                  opacity: 1,
                                  duration: Duration(milliseconds: 500),
                                  child: FlatButton(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    child: Text(
                                      "we've sent you an email!",
                                    ),
                                    textColor: Color(0xFFFE2562),
                                    onPressed: () {},
                                  ),
                                )
                              : _buildActionButton('reset')),
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        child: _buildSectionTitle('payment method'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                          child:
                              UpdatePaymentForm(onCardChange: updateCardInfo)),
                      _buildDivider(targetWidth, true),
                      Center(child: _buildActionButton('update')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
