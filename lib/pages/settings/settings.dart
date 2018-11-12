import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:shared_preferences/shared_preferences.dart';
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
  Map<String, dynamic> userSettings = {
    'email': 'clamptron@gmail.com',
    'theme': false,
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
      children: <Widget>[
        Text('dark-theme'),
        Container(
          margin: EdgeInsets.only(left: 178),
          child: CupertinoSwitch(
            value: userSettings['theme'],
            activeColor: Color(0xFFFE2562),
            onChanged: (bool val) {
              print(val);
              setState(() {
                userSettings['theme'] = !userSettings['theme'];
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailRow() {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('email'),
        Container(
          margin: EdgeInsets.only(left: 72),
          width: 200,
          child: TextField(
            decoration: InputDecoration(
                labelText: userSettings['email'],
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(right: 10)),
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
              _resetPassword();
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

  void _resetPassword() {
    _model.resetPassword(userSettings['email']);
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
          title: Text('settings', style: TextStyle(fontSize: 23),),
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
                  _buildDarkThemeRow(),
                  _buildDivider(targetWidth, false),
                  _buildEmailRow(),
                  _buildDivider(targetWidth, false),
                  Center(
                      child: model.isLoading
                          ? CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white))
                          : _buildActionButton('reset')),
                  SizedBox(
                    height: 40,
                  ),
                  _buildSectionTitle('payment method'),
                  SizedBox(
                    height: 20,
                  ),
                  UpdatePaymentForm(onCardChange: updateCardInfo),
                  _buildDivider(targetWidth, true),
                  Center(child: _buildActionButton('update')),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
