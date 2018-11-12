import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:snuze/pages/settings/update_payment_form.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SettingsPageState();
  }
}

class _SettingsPageState extends State<SettingsPage> {
  Map<String, dynamic> userSettings = {
    'email': 'test@test.com',
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

  void _getUserSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String userEmail = prefs.getString('userEmail');
    userSettings['email'] = userEmail;
    // final String userTheme = prefs.getString('userTheme');
    // final String userCardInfo = prefs.getString('userCardInfo');
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
            value: false,
            onChanged: (bool val) {
              print(val);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmailRow() {
    return Row(
      children: <Widget>[
        Text('email'),
        Container(
          margin: EdgeInsets.only(left: 160),
          width: 110,
          child: TextField(
            decoration: InputDecoration(
                labelText: userSettings['email'], border: InputBorder.none),
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

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      appBar: AppBar(
        title: Text('settings'),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        actions: <Widget>[
          FlatButton(
            child: Text('done', style: TextStyle(fontSize: 15),),
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
                Center(child: _buildActionButton('reset')),
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
  }
}
