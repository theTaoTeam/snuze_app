import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';

import 'package:snuze/pages/settings/update_payment_form.dart';
import 'package:snuze/scoped-models/main.dart';

class SettingsPage extends StatefulWidget {
  final MainModel model;

  SettingsPage({this.model});

  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState(model: model);
  }
}

class _SettingsPageState extends State<SettingsPage> {
  final MainModel model;

  _SettingsPageState({this.model});

  bool _sentPassword = false;
  bool _missingEmail = false;
  Map<String, dynamic> userSettings = {
    'email': '',
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
    super.initState();
    setState(() {
      userSettings['email'] = model.user.email;
      userSettings['darkTheme'] = model.user.darkTheme;
    });
    print('userSettings after setState: $userSettings');
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: TextStyle(
            color: Theme.of(context).dividerColor,
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
            style:
                TextStyle(fontSize: 15, color: Theme.of(context).disabledColor),
          ),
        ),
        Container(
          child: CupertinoSwitch(
            value: userSettings['darkTheme'],
            activeColor: Theme.of(context).primaryColor,
            onChanged: (bool val) {
              print(val);
              setState(() {
                userSettings['darkTheme'] = val;
              });
              model.saveUserSettings(userSettings);
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
          child: Text(
            'email',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ),
        Container(
          width: 200,
          child: TextField(
            style: TextStyle(color: Theme.of(context).highlightColor),
            decoration: InputDecoration(
              labelText: _missingEmail
                  ? 'please enter an email first'
                  : model.user.email,
              labelStyle: _missingEmail
                  ? TextStyle(color: Theme.of(context).primaryColor)
                  : TextStyle(color: Theme.of(context).disabledColor),
              border: InputBorder.none,
            ),
            onChanged: (String val) {
              setState(() {
                userSettings['email'] = val;
              });
              model.saveUserSettings(userSettings);
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
          color: Theme.of(context).dividerColor,
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
            textColor: Theme.of(context).primaryColor,
            onPressed: () {
              print('pressed reset password');
              model.resetPassword(userSettings['email']).then((message) {
                if (userSettings['email'] == '') {
                  setState(() {
                    _missingEmail = true;
                  });
                } else {
                  setState(() {
                    _sentPassword = true;
                  });
                  Timer(Duration(seconds: 5), () {
                    setState(() {
                      _sentPassword = false;
                    });
                  });
                }
              });
            },
          )
        : FlatButton(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            child: Text(
              'update card info',
            ),
            textColor: Theme.of(context).primaryColor,
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

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          'settings',
          style: TextStyle(fontSize: 23, color: Theme.of(context).dividerColor),
        ),
        actions: <Widget>[
          FlatButton(
            highlightColor: Colors.transparent,
            child: Text('logout', style: TextStyle(color: Theme.of(context).primaryColor),),
            color: Theme.of(context).backgroundColor,
            onPressed: () {
              model.logout();
            },
          )
        ],
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Theme.of(context).backgroundColor,
        iconTheme: IconThemeData(
          color: Theme.of(context).highlightColor, //change your color here
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          reverse: true,
          child: Container(
            margin: Platform.isIOS
                ? EdgeInsets.only(bottom: 100)
                : EdgeInsets.only(bottom: 50),
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
                                  textColor: Theme.of(context).highlightColor,
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
                    UpdatePaymentForm(onCardChange: updateCardInfo),
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
  }
}
