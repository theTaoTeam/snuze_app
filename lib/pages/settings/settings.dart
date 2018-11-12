import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
    State<StatefulWidget> createState() {
      return _SettingsPageState();
    }
}

class _SettingsPageState extends State<SettingsPage> {
  

  Future<Map<String, dynamic>> _getUserSettings() async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final String userTheme = prefs.getString('userTheme');
    // final String userCardInfo = prefs.getString('userCardInfo');
    Map<String, dynamic> userSettings = {
      'email': prefs.getString('userEmail'),
      'theme': false,
      'cardInfo': '',
    };
    
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

  Future<Widget> _buildEmailRow() async {
    return Row(
      children: <Widget>[
        Text('email'),
        Container(
          margin: EdgeInsets.only(left: 178),
          child: Text(userEmail),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double deviceWidth = MediaQuery.of(context).size.width;
    final double targetWidth = deviceWidth > 550.0 ? 500.0 : deviceWidth * 0.75;
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: Center(
        child: Container(
          width: targetWidth,
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Text('settings'),
              ),
              _buildDarkThemeRow(),
              SizedBox(
                width: targetWidth,
                height: 30.0,
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(left: 60),
                    height: 1,
                    color: Color(0xFFA1A1A1),
                  ),
                ),
              ),
              _buildEmailRow(),
            ],
          ),
        ),
      ),
    );
  }
}
